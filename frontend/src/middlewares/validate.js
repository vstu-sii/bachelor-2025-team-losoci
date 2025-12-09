export async function validate(schema, data) {
    try {
        await schema.validate(data, { abortEarly: false })
        return { valid: true, errors: {} }
    } catch (err) {
        const errors = {}

        if (
            err.name === "ValidationError" &&
            err.inner &&
            err.inner.length > 0
        ) {
            err.inner.forEach((e) => {
                if (errors[e.path]) {
                    errors[e.path] += `, ${e.message}`
                } else {
                    errors[e.path] = e.message
                }
            })
        } else if (err.path) {
            errors[err.path] = err.message
        }

        return { valid: false, errors }
    }
}
