import 'package:credidrivep_frontend_flutter/core/api/api_client.dart';
import 'package:credidrivep_frontend_flutter/core/constants/api_constants.dart';

import '../models/vehicle_model.dart';
import '../models/loan_plan_model.dart';
import '../models/simulation_result_model.dart';
import 'loan_remote_data_source.dart';

class LoanRemoteDataSourceImpl implements LoanRemoteDataSource {
  final ApiClient client;
  LoanRemoteDataSourceImpl({required this.client});

  @override
  Future<List<VehicleModel>> getVehicles() async {
    final r = await client.get(ApiConstants.vehicles);
    return (r.data as List).map((e) => VehicleModel.fromJson(e)).toList();
  }

  @override
  Future<List<LoanPlanModel>> getPlans() async {
    final r = await client.get(ApiConstants.loanPlans);
    return (r.data as List).map((e) => LoanPlanModel.fromJson(e)).toList();
  }

  @override
  Future<SimulationResultModel> simulate(Map<String, dynamic> payload) async {
    final r = await client.post(ApiConstants.simulate, data: payload);
    return SimulationResultModel.fromJson(r.data);
  }

  @override
  Future<SimulationResultModel> createLoan(Map<String, dynamic> payload) async {
    final r = await client.post(ApiConstants.loans, data: payload);
    return SimulationResultModel.fromJson(r.data);
  }

  @override
  Future<List<Map<String, dynamic>>> listLoans() async {
    final r = await client.get(ApiConstants.loans);
    return (r.data as List).cast<Map<String, dynamic>>();
  }
}
