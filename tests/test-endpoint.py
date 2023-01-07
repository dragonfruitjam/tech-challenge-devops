import unittest
import requests

class TestEndpoints(unittest.TestCase):     
    # Tests users only can access correct endpoints.
    def test_airport_endpoint_successs(self):
        res = requests.get('http://127.0.0.1:8080/airport', timeout=5)
        self.assertEqual( 200, res.status_code )

    def test_airport_endpoint_failure(self):
        res = requests.get('http://127.0.0.1:8080/airports', timeout=5)
        self.assertEqual( 501, res.status_code )

    def test_get_airport_successs(self):
        res = requests.get('http://127.0.0.1:8080/airport/AMS', timeout=5)
        self.assertEqual( 200, res.status_code )

    def test_get_airport_failure(self):
        res = requests.get('http://127.0.0.1:8080/airport/ABC', timeout=5)
        self.assertEqual( 500, res.status_code )

    def test_connection_endpoint_success(self):
        res = requests.get('http://127.0.0.1:8080/airport/AMS/to/ATH', timeout=5)
        self.assertEqual( 200, res.status_code )
    
    def test_connection_endpoint_failure(self):
        res = requests.get('http://127.0.0.1:8080/airport/ABC/to/DEF', timeout=5)
        self.assertEqual( 404, res.status_code )

    def test_vehicle_endpoint_success(self):
        res = requests.get('http://127.0.0.1:8080/vehicle/1/1', timeout=5)
        self.assertEqual( 200, res.status_code )
        res = requests.get('http://127.0.0.1:8080/vehicle/2/3', timeout=5)
        self.assertEqual( 200, res.status_code )
        res = requests.get('http://127.0.0.1:8080/vehicle/100/99', timeout=5)
        self.assertEqual( 200, res.status_code )

    def test_vehicle_endpoint_failure_incorrect_param_type(self):
        res = requests.get('http://127.0.0.1:8080/vehicle/abc/1', timeout=5)
        self.assertEqual( 501, res.status_code )
        res = requests.get('http://127.0.0.1:8080/vehicle/1/def', timeout=5)
        self.assertEqual( 501, res.status_code )
        res = requests.get('http://127.0.0.1:8080/vehicle/1.5/1', timeout=5)
        self.assertEqual( 501, res.status_code )
        res = requests.get('http://127.0.0.1:8080/vehicle/1/1.5', timeout=5)
        self.assertEqual( 501, res.status_code )

        
if __name__ == '__main__':
    unittest.main()