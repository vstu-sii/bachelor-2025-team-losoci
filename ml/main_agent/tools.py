"""Tools for the gift agent (web search via SearXNG + Яндекс Маркет)."""

from typing import Optional
import re
from urllib.parse import urlparse

import httpx
import orjson
from bs4 import BeautifulSoup
from langchain_core.tools import tool

_http_client: Optional[httpx.AsyncClient] = None

# Адрес локального SearXNG
SEARX_URL = "http://searxng:8080/search"

# Разрешённые домены (сейчас только Яндекс Маркет)
ALLOWED_DOMAINS = {"market.yandex.ru"}

# Заголовки для запросов к Маркету
HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/120.0 Safari/537.36"
    ),
    "Accept-Language": "ru-RU,ru;q=0.9,en;q=0.8",
}


def get_http_client() -> httpx.AsyncClient:
    """Создаёт или возвращает общий HTTP-клиент для SearXNG."""
    global _http_client
    if _http_client is None:
        _http_client = httpx.AsyncClient(timeout=10.0)
    return _http_client


async def fetch_html(url: str) -> str:
    """Скачать HTML страницы (например, карточка/категория Яндекс Маркета)."""
    try:
        async with httpx.AsyncClient(
            headers=HEADERS,
            follow_redirects=True,
            timeout=15.0,
        ) as client:
            resp = await client.get(url)
            resp.raise_for_status()
            return resp.text
    except httpx.HTTPStatusError as e:
        print(f"[HTTP ERROR] {e.response.status_code} for {url}")
        return ""
    except Exception as e:
        print(f"[ERROR] fetching {url}: {e}")
        return ""


def parse_market(html: str) -> dict:
    """
    Разобрать страницу Яндекс Маркета и вернуть
    ЛУЧШИЙ по количеству покупок товар на этой странице.

    Ищем товары в <article>, внутри которых есть блок с class="_1ENFO".
    Из него берём:
      - ссылку на товар (href -> https://market.yandex.ru + ...),
      - название,
      - рейтинг, отзывы, покупки,
      - цену из div._3iCDs.aP0JE.
    """
    soup = BeautifulSoup(html, "html.parser")
    products: list[dict] = []

    for art in soup.find_all("article"):
        info_block = art.select_one("._1ENFO")
        if not info_block:
            continue

        text = info_block.get_text(" ", strip=True)

        # --- ссылка на товар ---
        link_tag = info_block.find("a", href=True)
        product_url = None
        if link_tag:
            href = link_tag["href"]
            if href.startswith("/"):
                product_url = "https://market.yandex.ru" + href
            else:
                product_url = href

        # --- рейтинг ---
        rating = None
        m = re.search(r"Рейтинг товара:\s*([0-9.,]+)", text)
        if m:
            rating = m.group(1).replace(",", ".")

        # --- кол-во отзывов ---
        reviews = None
        m = re.search(r"Оценок:\s*\((\d+)\)", text)
        if m:
            try:
                reviews = int(m.group(1))
            except ValueError:
                reviews = None

        # --- покупки ("N купили"), берём максимум для карточки ---
        purchases = None
        matches = re.findall(r"(\d+)\s+купили", text)
        if matches:
            try:
                purchases = max(int(x) for x in matches)
            except ValueError:
                purchases = None

        # --- название ---
        title_tag = (
            info_block.find("h3")
            or info_block.find("h2")
            or info_block.find("a")
        )
        title = title_tag.get_text(strip=True) if title_tag else None

        # --- цена из div._3iCDs.aP0JE ---
        price = None
        price_block = art.select_one("div._3iCDs.aP0JE")
        if price_block:
            price_text = price_block.get_text(" ", strip=True)
            m = re.search(r"[\d\s]+₽", price_text)
            if m:
                price = m.group(0).strip()

        products.append(
            {
                "title": title,
                "price": price,
                "rating": rating,
                "reviews": reviews,
                "purchases": purchases,
                "product_url": product_url,
            }
        )

    if not products:
        return {
            "title": None,
            "price": None,
            "rating": None,
            "reviews": None,
            "purchases": None,
            "product_url": None,
        }

    # выбираем товар с максимальным числом покупок
    best = max(products, key=lambda p: p["purchases"] or 0)
    return best


@tool
async def search_web(query: str, num_results: int = 5) -> str:
    """
    Поиск через локальный SearXNG ТОЛЬКО по market.yandex.ru.

    1) Отправляет запрос в SearXNG.
    2) Оставляет только результаты, где домен market.yandex.ru.
    3) Для каждой такой ссылки:
       - скачивает страницу,
       - находит лучший по числу «купили» товар,
       - возвращает его данные.

    Возвращает JSON-строку списка словарей вида:
    {
      "position": <номер результата>,
      "title": "...",
      "url": "...",          # ссылка на конкретный товар
      "price": "...",
      "rating": "...",
      "reviews": <int | null>,
      "purchases": <int | null>
    }
    """
    try:
        client = get_http_client()
        response = await client.get(
            SEARX_URL,
            params={"q": query, "format": "json"},
        )
        response.raise_for_status()
        data = response.json()
        results = data.get("results", [])

        # фильтруем только Маркет
        filtered = []
        for r in results:
            url = r.get("url") or ""
            if not url:
                continue
            host = urlparse(url).netloc.lower()
            if host in ALLOWED_DOMAINS:
                filtered.append(r)

        filtered = filtered[:num_results]

        products: list[dict] = []
        for i, item in enumerate(filtered, 1):
            url = item.get("url")
            if not url:
                continue

            html = await fetch_html(url)
            if not html:
                continue

            best = parse_market(html)
            if not best or all(v is None for v in best.values()):
                continue

            products.append(
                {
                    "position": i,
                    "title": best["title"] or item.get("title") or "",
                    "url": best["product_url"] or url,
                    "price": best["price"],
                    "rating": best["rating"],
                    "reviews": best["reviews"],
                    "purchases": best["purchases"],
                }
            )

        return orjson.dumps(products, option=orjson.OPT_INDENT_2).decode()

    except httpx.HTTPStatusError as e:
        return orjson.dumps(
            {"error": f"SearXNG вернул HTTP {e.response.status_code} при запросе: {query}"}
        ).decode()
    except Exception as e:
        return orjson.dumps({"error": f"Search failed: {str(e)}"}).decode()


__all__ = ["search_web", "get_http_client"]
