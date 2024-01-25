class ApiLoggerModel {
  String requestMethod;
  int statusCode;
  String pathURL;
  String requestData;
  String responseData;
  String logTime;

  ApiLoggerModel({
    required this.requestMethod,
    required this.statusCode,
    required this.pathURL,
    required this.requestData,
    required this.responseData,
    required this.logTime,
  });

  ApiLoggerModel.fromJson(Map<String, dynamic> json)
      : requestMethod = json['request_method'],
        statusCode = json['status_code'],
        pathURL = json['path_url'],
        requestData = json['request_data'],
        responseData = json['response_data'],
        logTime = json['log_time'];

  Map<String, dynamic> toJson() => {
        'request_method': requestMethod,
        'status_code': statusCode,
        'path_url': pathURL,
        'request_data': requestData,
        'response_data': responseData,
        'log_time': logTime,
      };
}
