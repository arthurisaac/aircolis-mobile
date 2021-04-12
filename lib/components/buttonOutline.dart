import 'package:aircolis/utils/constants.dart';
import 'package:flutter/material.dart';

class AirButtonOutline extends StatelessWidget {
  final Function onPressed;
  final Widget text;
  const AirButtonOutline({Key key, this.onPressed, this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(padding),
          ),
          primary: Theme.of(context).primaryColor
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: padding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            text,
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.all(Radius.circular(space)),
                color:
                Theme.of(context).accentColor,
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
            )
          ],
        ),
      ),
    );
  }
}
