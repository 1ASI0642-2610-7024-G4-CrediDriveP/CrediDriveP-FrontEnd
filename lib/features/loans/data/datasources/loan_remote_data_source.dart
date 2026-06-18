import '../models/vehicle_model.dart';
import '../models/loan_plan_model.dart';
import '../models/simulation_result_model.dart';

abstract class LoanRemoteDataSource {
  Future<List<VehicleModel>> getVehicles();
  Future<List<LoanPlanModel>> getPlans();
  Future<SimulationResultModel> simulate(Map<String, dynamic> payload);
  Future<SimulationResultModel> createLoan(Map<String, dynamic> payload);
  Future<List<Map<String, dynamic>>> listLoans();
  Future<SimulationResultModel?> getLoanDetail(int id);
  Future<void> deleteLoan(int id);
}
