from endpoints.endpoint import Endpoint
from exceptions.bad_request_exception import BadRequestException

from helpers.log_utils import log_config
log = log_config("JourneyEndpoint")

class VehicleEndpoint(Endpoint):
    def __init__(self):
        super().__init__("vehicle", param="{numberOfPeople}/{distance}")
        self.vehicles = {
            "car": {"passengers_per_booking": 4, "cost_per_mile": .2, "parking_fee": 3.0},
            "taxi": {"passengers_per_booking": 4, "cost_per_mile": .4,  "parking_fee": 0.0},
            "airplane": {"passengers_per_booking": 1, "cost_per_mile": .1,  "parking_fee": 0.0}
        }

    def query_vehicle(self, passenger_no: int, miles: int):
        vehicle_costs = []
        for vehicle_name, vehicle in self.vehicles.items():
            no_of_bookings = self.ceildiv(passenger_no, vehicle["passengers_per_booking"])
            cost = no_of_bookings * (miles*vehicle["cost_per_mile"]) + no_of_bookings*vehicle["parking_fee"]
            vehicle_costs.append((vehicle_name, "%.2f" % cost))
        
        vehicle_costs = sorted(vehicle_costs, key=lambda x: x[1])
        cheapest_vehicle = vehicle_costs[0][0]
        cheapest_cost = vehicle_costs[0][1]

        return { 
            "cheapest_vehicle": cheapest_vehicle,
            "cost": cheapest_cost
        }

    def get_single(self, event):
        try:
            numberOfPeople = int(event["pathParameters"]["numberOfPeople"])
        except:
            raise BadRequestException("No parameter {numberOfPeople} found in URL path")
        
        try:
            distance = int(event["pathParameters"]["distance"])
        except:
            raise BadRequestException("No parameter {distance} found in URL path")

        # log.debug("Creating a graph with all airports...")
        # try:
        #     graph = makeGraph(models_Airport.get_all())
        # except Exception as e:
        #     raise HolidayAgencyException("Something's gone wrong generating the graph :(", e) from e

        # if origin_airport not in graph:
        #     raise NotFoundException(f"Origin airport '{origin_airport}' cannot be found")
        # if destination_airport not in graph:
        #     raise NotFoundException(f"Destination airport '{destination_airport}' cannot be found")

        # log.debug(f"Getting route from {origin_airport} to {destination_airport}")
        # try:
        #     journey_info = shortest_distance(graph, origin_airport, destination_airport)
        # except Exception as e:
        #     raise HolidayAgencyException("Something's gone wrong while calculating the journey :(", e) from e

        # log.debug("Found a route!")
        return 200, self.query_vehicle(numberOfPeople, distance)

    def ceildiv(self, a, b):
        return -(a // -b)

