import unittest
import json
from math import nan

def main(service):
    working_payload = {}
    assert service.run(json.dumps(working_payload)) == [{}]
    
    missing_col_payload = {}
    assert service.run(json.dumps(missing_col_payload)) == [{}]

    broken_json_payload = """{}"""
    assert str(service.run(json.dumps(broken_json_payload))) == str({})

if __name__ == "__main__":
    main()
