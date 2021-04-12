import 'package:aircolis/utils/constants.dart';
import 'package:flutter/material.dart';

/*class AirButton extends StatelessWidget {
  final Function onPressed;
  final Widget text;
  final IconData icon;
  const AirButton({Key key, this.onPressed, this.text, this.icon}) : super(key: key);
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
                Theme.of(context).primaryColorLight,
              ),
              child: Icon(
                icon ?? Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
            )
          ],
        ),
      ),
    );
  }
}*/

class AirDangerButton extends StatelessWidget {
  final Function onPressed;
  final Widget text;
  final IconData icon;
  const AirDangerButton({Key key, this.onPressed, this.text, this.icon}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(padding),
          ),
          primary: Colors.red
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
                color: Colors.red[300],
              ),
              child: Icon(
                icon ?? Icons.delete,
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

class AirButton extends StatelessWidget {
  final Function onPressed;
  final Widget text;
  final IconData icon;
  final Color color;
  final Color iconColor;
  const AirButton({Key key, this.onPressed, this.text, this.icon, this.color, this.iconColor}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(padding),
          ),
          primary: color ?? Theme.of(context).primaryColor
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
                color: iconColor ?? Theme.of(context).primaryColorLight,
              ),
              child: Icon(
                icon ?? Icons.arrow_forward_ios,
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