# notiyou

- [Dependencies](#dependencies)
- [Terminology](#terminology)

## Dependencies

```sh
flutter pub add go_router
```

## Terminology

서비스 내에서 사용되는 용어들을 정리합니다. 가급적 코드레벨에서도 해당 용어를 준수합니다.

1. 미션 시간 (Mission Time)

   - 사용자가 미션을 수행해야 하는 시간

2. 미션 (Mission)

   - 사용자가 매일 수행해야 하는 작업.
   - 미션 시간에 체크를 해야하며, 체크를 하지 않으면 본인과 조력자에게 알림이 간다.
   - 매일 자정이 지나면 설정해둔 미션 시간으로 새로운 미션들이 생성된다.

3. 미션 알림 메시지 (Mission Notification Message)

   - 미션 수행과 관련된 알림 메시지. 조력자에게 해당 메시지가 전달된다.
   - 미션 수행 성공 또는 실패 여부에 따라 다른 메시지가 전달된다.

4. 조력자 (Supporter)

   - 사용자의 미션 수행을 돕는 역할
   - 미션 알림을 확인하고 사용자의 미션 완료 여부를 검증하는 사람
