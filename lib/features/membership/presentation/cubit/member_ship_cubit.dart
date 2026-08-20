import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'member_ship_state.dart';

class MemberShipCubit extends Cubit<MemberShipState> {
  MemberShipCubit() : super(MemberShipInitial());
}
