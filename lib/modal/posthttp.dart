class PostHttp {
  final bool status;
  final String link;
  final Map<String, dynamic> data;

  PostHttp({
    this.status,
    this.link,
    this.data
  });

  factory PostHttp.fromJson(Map<String, dynamic> json){
    return new PostHttp(
      status: json['status'],
      data: json['data']
    );
  }
}

class GetHttp {
  final List<dynamic> files;


  GetHttp({
    this.files,
  });

  factory GetHttp.fromJson(Map<String, dynamic> json){
    return new GetHttp(
      files: json['files'],
    );
  }
}


class PostHttpList {
  final bool status;
  final List<dynamic> data;
  final String timedata;
  final bool timestatus;
  PostHttpList({
    this.status,
    this.data,
    this.timedata,
    this.timestatus
  });

  factory PostHttpList.fromJson(Map<String, dynamic> json){
    return new PostHttpList(
        status: json['status'],
        data: json['data']['fileListModalList'],
      timedata: json['data']['time'],
        timestatus: json['data']['timeStatus']

    );
  }
}



