class Meta {
  int? currentPage;
  int? totalPages;
  int? totalDataCount;

  Meta({this.currentPage, this.totalPages, this.totalDataCount});

  Meta.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    totalPages = json['total_pages'];
    totalDataCount = json['total_data_count'];
  }
}
