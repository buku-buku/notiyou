import 'package:flutter/widgets.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_friend.dart';

class KakaoPickerService {
  static final PickerApi _pickerApi = PickerApi.instance;

  static Future selectSingleFriend(BuildContext context) async {
    try {
      final result = await _pickerApi.selectFriends(
        params: PickerFriendRequestParams(
          title: '서포터 선택',
          enableSearch: true,
          showMyProfile: false,
          showFavorite: true,
          // showPickedFriend: true, // 선택한 친구 표시 여부, 멀티 피커에만 사용 가능
          maxPickableCount: 1,
          minPickableCount: 1,
        ),
        context: context,
      );

      if (result.users.isNotEmpty) {
        return result.users.first;
      }
      return null;
    } catch (error) {
      print('카카오 친구 피커 에러: $error');
      rethrow; // 에러를 상위로 전달하여 UI에서 처리할 수 있도록 함
    }
  }
}
