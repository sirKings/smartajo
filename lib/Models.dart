
class Coop {

  String name;
  String creator;
  String number;
  String amount;
  int createdAt;
  String id;
  String creatorName;
  String code;
  String period;
  String startDate;

  Coop(Map map){
    this.name = map["name"];
    this.number = map["number"];
    this.id = map["id"];
    this.creator = map["creator"];
    this.amount = map["amount"];
    this.createdAt = map["createdAt"];
    this.creatorName = map["creatorName"];
    this.code = map["code"];
    this.startDate = map["startDate"];
    this.period = map["period"];
  }

  String getAvartar(){
    return "${this.name.substring(0,2).toUpperCase()}";
  }
}

class LocalUser {
  String name;
  String email;
  String phone;
  String id;
  String chargeCode;

  LocalUser(Map map){
    this.name = map["name"];
    this.email = map["email"];
    this.phone = map["phone"];
    this.id = map["id"];
    if(map["chargeCode"] == null){
      this.chargeCode = "";
    }else{
      this.chargeCode = map[chargeCode];
    }
  }

  String getInitiials(){
    List<String> arr = this.name.split(" ");
    var res = "";
    if(arr.length > 1){
      res = "${arr[0][0]}${arr[1][0]}";
    }else{
      res = "${arr[0][0]}${arr[0][1]}";
    }
    print(res);
    return res.toUpperCase();
  }
}

class CMember {
  String name;
  String email;
  String phone;
  String id;
  int position;

  CMember(Map map){
    this.name = map["name"];
    this.email = map["email"];
    this.phone = map["phone"];
    this.id = map["id"];
    this.position = map["position"];
  }

  String getInitiials(){
    List<String> arr = this.name.split(" ");
    var res = "";
    if(arr.length > 1){
      res = "${arr[0][0]}${arr[1][0]}";
    }else{
      res = "${arr[0][0]}${arr[0][1]}";
    }
    print(res);
    return res.toUpperCase();
  }
}

class Payment {

  String id;
  int amount;
  int date;
  String coopId;
  bool isPaid;
  String userId;
  String coopName;

  Payment(Map map){
    this.id = map["id"];
    this.isPaid = map["isPaid"];
    this.amount = map["amount"];
    this.date = map["date"];
    this.coopId = map["coopId"];
    this.userId = map["userId"];
    this.coopName = map["coopName"];
  }
}



class CardP {

  String number;
  String chargeCode;
  String creator;
  int createdAt;
  String id;
  String creatorName;

  CardP(Map map){
    this.chargeCode = map["chargeCode"];
    this.number = map["number"];
    this.id = map["id"];
    this.creator = map["creator"];
    this.createdAt = map["createdAt"];
    this.creatorName = map["creatorName"];
  }
}

class CoopDetailsPageArgument {

  bool isJoining;
  Coop coop;

}