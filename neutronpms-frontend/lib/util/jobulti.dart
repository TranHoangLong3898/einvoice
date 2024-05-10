import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/util/messageulti.dart';

class JobUlti {
  static final List<String> jobsInCloud = [
    MessageCodeUtil.JOB_CHOOSE,
    MessageCodeUtil.JOB_ACCOUNTANT,
    MessageCodeUtil.JOB_HOUSEKEEPING,
    MessageCodeUtil.JOB_CHEF,
    MessageCodeUtil.JOB_GUARD,
    MessageCodeUtil.JOB_MAINTAINER,
    MessageCodeUtil.JOB_WAITER_WAITRESS,
    MessageCodeUtil.JOB_RECEPTIONIST,
    MessageCodeUtil.JOB_HR,
    MessageCodeUtil.JOB_MARKETING,
    MessageCodeUtil.JOB_SALE,
    MessageCodeUtil.JOB_STEPWARD,
    MessageCodeUtil.JOB_MANAGER,
    MessageCodeUtil.JOB_OWNER,
    MessageCodeUtil.JOB_OTHER,
    MessageCodeUtil.JOB_PARTNER,
    MessageCodeUtil.JOB_APPROVER,
    MessageCodeUtil.JOB_INTERNAL_PARTNER,
  ];

  static List<String> getJobs() {
    return jobsInCloud.map((e) => MessageUtil.getMessageByCode(e)).toList();
  }

  static String? convertJobNameFromEnToLocal(String? job) {
    if (job == null) return null;
    Iterable<Map<String, String>?> jobMaps = MessageUtil.messageMap.values
        .toList()
        .where((element) => element!['en']!.toLowerCase() == job.toLowerCase());
    if (jobMaps.isEmpty) {
      return job;
    }
    if (jobMaps.length == 1) {
      return jobMaps.first![GeneralManager.locale!.toLanguageTag()];
    }
    String result = '';
    for (var element in jobMaps) {
      if (element!['en'] == job) {
        result = element[GeneralManager.locale!.toLanguageTag()]!;
        continue;
      }
    }
    return result;
  }

  static String convertJobNameFromLocalToEn(String job) {
    Iterable<Map<String, String>?> jobMaps = MessageUtil.messageMap.values
        .toList()
        .where((element) =>
            element![GeneralManager.locale!.toLanguageTag()]!.toLowerCase() ==
            job.toLowerCase());
    if (jobMaps.isEmpty) {
      return job;
    }
    if (jobMaps.length == 1) {
      return jobMaps.first!['en']!;
    }
    String result = '';
    for (var element in jobMaps) {
      if (element![GeneralManager.locale!.toLanguageTag()] == job) {
        result = element['en']!;
        continue;
      }
    }
    return result;
  }
}
