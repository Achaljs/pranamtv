class ContestModel {
  String? remark;
  String? status;
  Data? data;

  ContestModel({this.remark, this.status, this.data});

  ContestModel.fromJson(Map<String, dynamic> json) {
    remark = json['remark'];
    status = json['status'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['remark'] = this.remark;
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<NewContests>? newContests;
  List<NewContests>? oldContests;

  Data({this.newContests, this.oldContests});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['new_contests'] != null) {
      newContests = <NewContests>[];
      json['new_contests'].forEach((v) {
        newContests!.add(new NewContests.fromJson(v));
      });
    }
    if (json['old_contests'] != null) {
      oldContests = <NewContests>[];
      json['old_contests'].forEach((v) {
        oldContests!.add(new NewContests.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.newContests != null) {
      data['new_contests'] = this.newContests!.map((v) => v.toJson()).toList();
    }
    if (this.oldContests != null) {
      data['old_contests'] = this.oldContests!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class NewContests {
  int? id;
  String? title;
  String? img;
  String? img2;
  String? miniDesc;
  String? description;
  String? starttime;
  String? endtime;
  String? date;
  String? enddata;
  int? commingSoon;
  int? stage;
  int? votingStatus;
  String? contestTermCondition;
  String? char1;
  String? char2;
  String? char3;
  String? char4;
  String? char5;
  String? char6;
  String? char7;
  String? char8;
  String? char9;
  String? char10;
  String? char11;
  String? char12;
  String? char13;
  String? char14;
  String? char15;
  String? char16;
  String? char17;
  String? char18;
  String? char19;
  String? char20;
  String? charDesc1;
  String? charDesc2;
  String? charDesc3;
  String? charDesc4;
  String? charDesc5;
  String? charDesc6;
  String? charDesc7;
  String? charDesc8;
  String? charDesc9;
  String? charDesc10;
  String? charDesc11;
  String? charDesc12;
  String? charDesc13;
  String? charDesc14;
  String? charDesc15;
  String? charDesc16;
  String? charDesc17;
  String? charDesc18;
  String? charDesc19;
  String? charDesc20;

  NewContests(
      {this.id,
        this.title,
        this.img,
        this.img2,
        this.miniDesc,
        this.description,
        this.starttime,
        this.endtime,
        this.date,
        this.enddata,
        this.commingSoon,
        this.stage,
        this.votingStatus,
        this.contestTermCondition,
        this.char1,
        this.char2,
        this.char3,
        this.char4,
        this.char5,
        this.char6,
        this.char7,
        this.char8,
        this.char9,
        this.char10,
        this.char11,
        this.char12,
        this.char13,
        this.char14,
        this.char15,
        this.char16,
        this.char17,
        this.char18,
        this.char19,
        this.char20,
        this.charDesc1,
        this.charDesc2,
        this.charDesc3,
        this.charDesc4,
        this.charDesc5,
        this.charDesc6,
        this.charDesc7,
        this.charDesc8,
        this.charDesc9,
        this.charDesc10,
        this.charDesc11,
        this.charDesc12,
        this.charDesc13,
        this.charDesc14,
        this.charDesc15,
        this.charDesc16,
        this.charDesc17,
        this.charDesc18,
        this.charDesc19,
        this.charDesc20});

  NewContests.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    img = json['img'];
    img2 = json['img2'];
    miniDesc = json['mini_desc'];
    description = json['description'];
    starttime = json['starttime'];
    endtime = json['endtime'];
    date = json['date'];
    enddata = json['enddata'];
    commingSoon = json['comming_soon'];
    stage = json['stage'];
    votingStatus = json['voting_status'];
    contestTermCondition = json['contest_term_condition'];
    char1 = json['char1'];
    char2 = json['char2'];
    char3 = json['char3'];
    char4 = json['char4'];
    char5 = json['char5'];
    char6 = json['char6'];
    char7 = json['char7'];
    char8 = json['char8'];
    char9 = json['char9'];
    char10 = json['char10'];
    char11 = json['char11'];
    char12 = json['char12'];
    char13 = json['char13'];
    char14 = json['char14'];
    char15 = json['char15'];
    char16 = json['char16'];
    char17 = json['char17'];
    char18 = json['char18'];
    char19 = json['char19'];
    char20 = json['char20'];
    charDesc1 = json['char_desc1'];
    charDesc2 = json['char_desc2'];
    charDesc3 = json['char_desc3'];
    charDesc4 = json['char_desc4'];
    charDesc5 = json['char_desc5'];
    charDesc6 = json['char_desc6'];
    charDesc7 = json['char_desc7'];
    charDesc8 = json['char_desc8'];
    charDesc9 = json['char_desc9'];
    charDesc10 = json['char_desc10'];
    charDesc11 = json['char_desc11'];
    charDesc12 = json['char_desc12'];
    charDesc13 = json['char_desc13'];
    charDesc14 = json['char_desc14'];
    charDesc15 = json['char_desc15'];
    charDesc16 = json['char_desc16'];
    charDesc17 = json['char_desc17'];
    charDesc18 = json['char_desc18'];
    charDesc19 = json['char_desc19'];
    charDesc20 = json['char_desc20'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['img'] = this.img;
    data['img2'] = this.img2;
    data['mini_desc'] = this.miniDesc;
    data['description'] = this.description;
    data['starttime'] = this.starttime;
    data['endtime'] = this.endtime;
    data['date'] = this.date;
    data['enddata'] = this.enddata;
    data['comming_soon'] = this.commingSoon;
    data['stage'] = this.stage;
    data['voting_status'] = this.votingStatus;
    data['contest_term_condition'] = this.contestTermCondition;
    data['char1'] = this.char1;
    data['char2'] = this.char2;
    data['char3'] = this.char3;
    data['char4'] = this.char4;
    data['char5'] = this.char5;
    data['char6'] = this.char6;
    data['char7'] = this.char7;
    data['char8'] = this.char8;
    data['char9'] = this.char9;
    data['char10'] = this.char10;
    data['char11'] = this.char11;
    data['char12'] = this.char12;
    data['char13'] = this.char13;
    data['char14'] = this.char14;
    data['char15'] = this.char15;
    data['char16'] = this.char16;
    data['char17'] = this.char17;
    data['char18'] = this.char18;
    data['char19'] = this.char19;
    data['char20'] = this.char20;
    data['char_desc1'] = this.charDesc1;
    data['char_desc2'] = this.charDesc2;
    data['char_desc3'] = this.charDesc3;
    data['char_desc4'] = this.charDesc4;
    data['char_desc5'] = this.charDesc5;
    data['char_desc6'] = this.charDesc6;
    data['char_desc7'] = this.charDesc7;
    data['char_desc8'] = this.charDesc8;
    data['char_desc9'] = this.charDesc9;
    data['char_desc10'] = this.charDesc10;
    data['char_desc11'] = this.charDesc11;
    data['char_desc12'] = this.charDesc12;
    data['char_desc13'] = this.charDesc13;
    data['char_desc14'] = this.charDesc14;
    data['char_desc15'] = this.charDesc15;
    data['char_desc16'] = this.charDesc16;
    data['char_desc17'] = this.charDesc17;
    data['char_desc18'] = this.charDesc18;
    data['char_desc19'] = this.charDesc19;
    data['char_desc20'] = this.charDesc20;
    return data;
  }
}