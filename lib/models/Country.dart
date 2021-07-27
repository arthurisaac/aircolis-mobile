class Countries {
  String url;
  String alpha3;
  String fileUrl;
  String name;
  String license;

  Countries({this.url, this.alpha3, this.fileUrl, this.name, this.license});

  Countries.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    alpha3 = json['alpha3'];
    fileUrl = json['file_url'];
    name = json['name'];
    license = json['license'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['alpha3'] = this.alpha3;
    data['file_url'] = this.fileUrl;
    data['name'] = this.name;
    data['license'] = this.license;
    return data;
  }
}
