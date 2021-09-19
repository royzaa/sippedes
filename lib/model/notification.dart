class NotificationModel {
  final String title, body, readStatus, date;

  NotificationModel(
      {required this.title,
      required this.body,
      required this.date,
      required this.readStatus});

  // factory NotificationModel.createNotificationModel(Map<String, dynamic> data) {
  //   return NotificationModel(
  //       title: data['letterName'],
  //       body:
  //           'Pengajuan surat anda untuk ${data['letterName']} berstatus sudah ${data['progressStatus']}',
  //       date: data['lastChanged'],
  //       readStatus: data['readStatus']);
  // }

}

class Notification {
  int _notifCount = 0;

  int get notifCount => _notifCount;

  void changeNotifCount(count) {
    _notifCount = count;
  }
}
