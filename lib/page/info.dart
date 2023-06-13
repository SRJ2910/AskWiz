import 'package:flutter/material.dart';

class info extends StatelessWidget {
  const info({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About AskWiz"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text('''
Reading and analysing texts to find answers have never been a simple task often riddled with mistakes, errors and inaccuracies. However, these problems will now not be a hinderance anymore with our ingenious app AskWiz -- Ask-Me-Anything.\n
All you have to do is upload the reference text via camera or gallery and witness the app do all the work for you. Once the concerned text is uploaded the app reads the text from the image via OCR i.e. (Optical Character Text Recognition). Upon asking the question from the reference text, the app utilises the Deep Learning Model – RoBERTa to take the input text and analyse the same in accordance to the question asked to produce factually accurate and quick results. 
\nThus, reducing manual work without compensating with the precision and the essence of the results.
Moreover, it has the capability to read lengthy documents and perform various errorless operations on them. It can produce short and crisp informative articles and literary results from vast unpolished texts and conclusions from research papers. It also holds immense potential in academic sector where it can churn out numerous meaningful questions on the directions of professors for quizzes and assignments, reducing load and revolutionising the classic approach to such works.
'''),
      ),
    );
  }
}
