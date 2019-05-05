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

  PostHttpList({
    this.status,
    this.data
  });

  factory PostHttpList.fromJson(Map<String, dynamic> json){
    return new PostHttpList(
        status: json['status'],
        data: json['data']
    );
  }
}



