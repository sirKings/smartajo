
import 'package:app/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleGenerator{

  Firestore _store = Firestore.instance;
  String startDate;
  int period;
  int memberCount;
  String amount;
  String coopId;
  int position;
  String coopName;
  String chargeCode;

  ScheduleGenerator(this.startDate, String periodStr, this.memberCount, this.amount, this.coopId, this.position, this.coopName, this.chargeCode){
    if(periodStr == Constants.D){
      this.period = 1;
    }else if(periodStr == Constants.W){
      this.period = 7;
    }else{
      this.period = 28;
    }
  }

  generateSchedule() async{

    List<String> components = startDate.split("/");

    int year = int.parse(components[2]);
    int month = int.parse(components[1]);
    int day = int.parse(components[0]);

    DateTime date = DateTime(year,month,day,0,0,0,0,0);

    for(var i = 0; i < memberCount; i++){
      date = date.add(Duration(days: period));

      DocumentReference ref = await _store.collection(Database.PAYMENTS).add({
        'date': date.millisecondsSinceEpoch,
        'userId': localUser.id,
        'amount': int.parse(amount),
        'coopsId': coopId,
        'isPaid': false,
        'coopName': coopName,
        'chargeCode': chargeCode
      });

      _store.collection(Database.PAYMENTS).document(ref.documentID).updateData({
        'id': ref.documentID
      });

      if(position == i){
        DocumentReference ref = await _store.collection(Database.COLLECTION).add({
          'date': date.millisecondsSinceEpoch,
          'userId': localUser.id,
          'amount': int.parse(amount) * memberCount,
          'coopsId': coopId,
          'isPaid': false,
          'coopName': coopName
        });

        _store.collection(Database.COLLECTION).document(ref.documentID).updateData({
          'id': ref.documentID
        });
      }

    }



  }

}