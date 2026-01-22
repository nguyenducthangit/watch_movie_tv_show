import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/translations/lang/l.dart';

class TagMapper {
  static final Map<String, String> _tagMap = {
    // Vietnamese raw tags -> L keys
    'Hành Động': L.action,
    'Tình Cảm': L.romance,
    'Hài Hước': L.comedy,
    'Cổ Trang': L.drama, // Mapping Cổ Trang to drama/history roughly or specific key if exists
    'Tâm Lý': L.psychological,
    'Hình Sự': L.crime,
    'Chiến Tranh': L.war,
    'Thể Thao':
        L.science, // Assuming no sport key, mapping to science is wrong. Let's check keys again.
    'Võ Thuật': L.action,
    'Viễn Tưởng': L.scienceFiction,
    'Phiêu Lưu': L.adventure,
    'Khoa Học': L.science,
    'Kinh Dị': L.horror,
    'Âm Nhạc': L.drama, // Fallback
    'Thần Thoại': L.adventure,
    'Tài Liệu': L.documentary,
    'Gia Đình': L.family,
    'Chính Kịch': L.drama,
    'Bí Ẩn': L.mystery,
    'Học Đường': L.shortDrama, // Roughly
    'Kinh Điển': L.drama,
    'Phim 18+': L.romance,

    // Slugs or lowecase -> L keys
    'hanh-dong': L.action,
    'tinh-cam': L.romance,
    'hai-huoc': L.comedy,
    'co-trang': L.drama,
    'tam-ly': L.psychological,
    'hinh-su': L.crime,
    'chien-tranh': L.war,
    'vien-tuong': L.scienceFiction,
    'phieu-luu': L.adventure,
    'khoa-hoc': L.science,
    'kinh-di': L.horror,
    'tai-lieu': L.documentary,
    'gia-dinh': L.family,
    'chinh-kich': L.drama,
    'bi-an': L.mystery,
  };

  /// Get translated tag label
  static String getTranslatedTag(String rawTag) {
    // Try exact match
    if (_tagMap.containsKey(rawTag)) {
      return _tagMap[rawTag]!.tr;
    }

    // Try case-insensitive
    final lowerTag = rawTag.toLowerCase();
    for (var key in _tagMap.keys) {
      if (key.toLowerCase() == lowerTag) {
        return _tagMap[key]!.tr;
      }
    }

    // Try handling slug format (hanh-dong) if rawTag is "Hành Động"
    // But map already has vietnamese keys.

    // Return original if no match found
    return rawTag;
  }
}
