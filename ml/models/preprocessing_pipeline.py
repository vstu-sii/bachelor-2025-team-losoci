import re
import pandas as pd

class DataPreprocessor:
    required_fields = ['id', 'sex', 'age', 'info']
    valid_sex_values = ['Мужской', 'Женский']
    
    @staticmethod
    def clean_text(text):
        if not isinstance(text, str):
            return ""
        return re.sub(r'\s+', ' ', text).strip()
    
    @classmethod
    def validate_single_row(cls, row_data):
        errors = []
        
        for field in cls.required_fields:
            if field not in row_data:
                errors.append(f"Missing field: {field}")
        
        if errors:
            return {"valid": False, "errors": errors}
        
        if row_data['sex'] not in cls.valid_sex_values:
            errors.append(f"Invalid sex: {row_data['sex']}")
        
        if not isinstance(row_data['info'], str) or len(row_data['info'].strip()) < 5:
            errors.append("Too short info description")
        
        return {
            "valid": len(errors) == 0,
            "errors": errors,
            "cleaned_info": cls.clean_text(row_data['info']) if 'info' in row_data else ""
        }
    
    @classmethod
    def check_single_row_quality(cls, row_data):
        quality_report = {
            "age": row_data['age'],
            "sex": row_data['sex'],
            "info_length": len(row_data['info']),
            "info_cleaned_length": len(cls.clean_text(row_data['info'])),
            "has_special_chars": bool(re.search(r'[^\w\sа-яА-ЯёЁ.,!?;:-]', row_data['info'])),
            "word_count": len(row_data['info'].split())
        }
        return quality_report
    
    @classmethod
    def preprocess_single_row(cls, row_data):
        processed_data = row_data.copy()
        processed_data['info_clean'] = cls.clean_text(row_data['info'])
        return processed_data
    
    @classmethod
    def test_single_row_pipeline(cls, row_data):
        validation_result = cls.validate_single_row(row_data)
        print(f"Valid: {validation_result['valid']}")
        
        if not validation_result['valid']:
            print("Errors:")
            for error in validation_result['errors']:
                print(f"  - {error}")
            return False
        
        #print("\nData Quality")
        quality_report = cls.check_single_row_quality(row_data)
        #print(f"Age: {quality_report['age']}")
        #print(f"Sex: {quality_report['sex']}")
        #print(f"Info length: {quality_report['info_length']}")
        #print(f"Cleaned length: {quality_report['info_cleaned_length']}")
        #print(f"Word count: {quality_report['word_count']}")
        #print(f"Has special chars: {quality_report['has_special_chars']}")
        
        #print("\nPreprocessing ")
        processed_row = cls.preprocess_single_row(row_data)
        #print(f"Original info: {row_data['info'][:100]}...")
        #print(f"Cleaned info: {processed_row['info_clean'][:100]}...")
        
        return processed_row
