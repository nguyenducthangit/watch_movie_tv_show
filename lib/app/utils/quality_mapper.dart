import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/translations/lang/l.dart';


class QualityMapper {
  static String translate(String? quality) {
    if (quality == null || quality.isEmpty) return '';

    final q = quality.trim();
    final lower = q.toLowerCase();


    if (lower == 'hd' || lower.contains('hd')) return L.hd.tr;
    if (lower == 'fhd' || lower.contains('fhd') || lower.contains('4k')) return L.fhd.tr;
    if (lower == 'sd') return L.sd.tr;
    if (lower.contains('full')) return L.full.tr;


    final match = RegExp(r'^(\d+)p\b', caseSensitive: false).firstMatch(q);
    if (match != null) {
      final num = match.group(1);
      return '${num}${L.p.tr}';
    }


    if (lower == 'auto') return L.auto.tr;


    return q;
  }
}
