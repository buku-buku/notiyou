import 'package:flutter/material.dart';
import 'package:notiyou/entities/current_participant.dart';

class PartnerInfoBanner extends StatelessWidget {
  final Partner? partner;
  final bool isChallenger;
  final VoidCallback? onTap;

  const PartnerInfoBanner({
    super.key,
    required this.partner,
    required this.isChallenger,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasPartner = partner != null;
    final backgroundColor = hasPartner ? Colors.green[100] : Colors.red[100];
    final textColor = hasPartner ? Colors.green[900] : Colors.red[900];

    return Container(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
        padding: const EdgeInsets.all(12.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: hasPartner
            ? Text(
                '${isChallenger ? "서포터" : "도전자"} ${partner!.name}님과 함께하는 미션입니다.',
                style: TextStyle(
                  color: textColor,
                ),
              )
            : InkWell(
                onTap: onTap,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(
                          '서포터 초대하러 가기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(width: 2.5),
                        Icon(Icons.person_add_alt_rounded,
                            size: 22, color: Colors.red),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      '소중한 서포터와 함께 미션을 수행해보세요!\n서포터가 초대를 수락하기 전까지는 혼자 미션을 수행하게 됩니다.',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
