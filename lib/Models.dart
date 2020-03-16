
class Coop {

  String name;
  String creator;
  String number;
  String amount;
  int createdAt;
  String id;
  String creatorName;
  String code;

  Coop(Map map){
    this.name = map["name"];
    this.number = map["number"];
    this.id = map["id"];
    this.creator = map["creator"];
    this.amount = map["amount"];
    this.createdAt = map["createdAt"];
    this.creatorName = map["creatorName"];
    this.code = map["code"];
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

  LocalUser(Map map){
    this.name = map["name"];
    this.email = map["email"];
    this.phone = map["phone"];
    this.id = map["id"];
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

  String ref;
  String creator;
  int amount;
  int createdAt;
  String id;
  String creatorName;
  String cooperativeId;

  Payment(Map map){
    this.ref = map["ref"];
    this.id = map["id"];
    this.creator = map["creator"];
    this.amount = map["amount"];
    this.createdAt = map["createdAt"];
    this.creatorName = map["creatorName"];
    this.cooperativeId = map["cooperativeId"];
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