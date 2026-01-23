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
    'Thể Thao': L.sport,
    'Võ Thuật': L.action,
    'Viễn Tưởng': L.scienceFiction,
    'Phiêu Lưu': L.adventure,
    'Khoa Học': L.science,
    'Kinh Dị': L.horror,
    'Âm Nhạc': L.music,
    'Thần Thoại': L.adventure,
    'Tài Liệu': L.documentary,
    'Gia Đình': L.family,
    'Chính Kịch': L.drama,
    'Bí Ẩn': L.mystery,
    'Học Đường': L.shortDrama, // Roughly
    'Kinh Điển': L.drama,
    'Phim 18+': L.romance,
    'Giả Tưởng': L.fantasy,
    'Hoạt Hình': L.animation,
    'Hồi Hộp': L.thriller,

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
    'the-thao': L.sport,
    'am-nhac': L.music,
    'gia-tuong': L.fantasy,
    'hoat-hinh': L.animation,
    'hoi-hop': L.thriller,

    // English raw tags -> L keys
    'Action': L.action,
    'Romance': L.romance,
    'Comedy': L.comedy,
    'Humor': L.comedy,
    'Drama': L.drama,
    'Psychological': L.psychological,
    'Crime': L.crime,
    'War': L.war,
    'Sport': L.sport,
    'Martial Arts': L.action,
    'Sci-Fi': L.scienceFiction,
    'Science Fiction': L.scienceFiction,
    'Adventure': L.adventure,
    'Science': L.science,
    'Horror': L.horror,
    'Music': L.music,
    'Mythology': L.adventure,
    'Documentary': L.documentary,
    'Family': L.family,
    'Mystery': L.mystery,
    'School': L.shortDrama,
    'Classic': L.drama,
    'Adult': L.romance,
    'Animation': L.animation,
    'Fantasy': L.fantasy,
    'Thriller': L.thriller,
    'Full': L.full,
    'full': L.full,
    'FULL': L.full,
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
