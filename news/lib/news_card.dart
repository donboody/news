import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:url_launcher/url_launcher.dart';

final _borderRadius = BorderRadius.circular(8.0);

class NewsCard extends StatelessWidget {
  final String source;
  final String title;
  final String subtitle;
  final String networkImageUrl;
  final ColorSwatch color;
  final String articleUrl;

  const NewsCard({
    Key key,
    @required this.source,
    @required this.title,
    @required this.subtitle,
    @required this.networkImageUrl,
    @required this.articleUrl,
    this.color,
  })  : assert(source != null),
        assert(title != null),
        assert(subtitle != null),
        assert(networkImageUrl != null),
        assert(articleUrl != null),
        super(key: key);

  Widget buildHeadlineByline(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.headline,
          ),
          SizedBox(
            height: 8,
          ),
          Text(subtitle),
        ],
      ),
    );
  }

  _launchURL() async {
    if (await canLaunch(articleUrl)) {
      await launch(articleUrl);
    } else {
      throw 'Could not launch $articleUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey[700], width: 1.0)),
      child: InkWell(
        highlightColor: Colors.transparent,
        borderRadius: _borderRadius,
        splashColor: Colors.grey,
        onTap: _launchURL,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Text(source),
              Container(
                padding: EdgeInsets.all(8.0),
                child: Image(
                  image: NetworkImage(networkImageUrl),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildHeadlineByline(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
