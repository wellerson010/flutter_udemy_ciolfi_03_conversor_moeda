import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

const String url = 'https://api.hgbrasil.com/finance?key=f300d973';

final dio = Dio();

void main() async{
  await getData();

  runApp(MaterialApp(
    title: 'Conversor de Moedas',
    home: Home(),
    theme: ThemeData(
      primaryColor: Colors.white
    ),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>{
  Model model;
  final _realController = TextEditingController();
  final _dollarController = TextEditingController();
  final _euroController = TextEditingController();

  void _clearAll(){
    _realController.clear();
    _dollarController.clear();
    _euroController.clear();
  }

  void _realChanged(String value){
    if (value.isEmpty){
      _clearAll();
      return;
    }
    double real = double.parse(value);
    _dollarController.text = (real/model.usd).toStringAsFixed(2);
    _euroController.text = (real/model.usd).toStringAsFixed(2);
  }

  void _dollarChanged(String value){
    if (value.isEmpty){
      _clearAll();
      return;
    }

    double dollar = double.parse(value);
    _realController.text = (dollar * model.usd).toStringAsFixed(2);
    _euroController.text = (dollar * model.usd / model.euro).toStringAsFixed(2);
  }

  void _euroChanged(String value){
    if (value.isEmpty){
      _clearAll();
      return;
    }

    double euro = double.parse(value);
    _realController.text = (euro * model.euro).toStringAsFixed(2);
    _euroController.text = (euro * model.euro / model.usd).toStringAsFixed(2);
  }

  TextField _buildInput(String label, String prefix, TextEditingController controller, Function(String) function){
    return TextField(
      controller: controller,
      onChanged: function,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: Colors.amber
          ),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Colors.amber
              )
          ),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Colors.amber
              )
          ),
          prefixText: prefix,
          hintStyle: TextStyle(
              color: Colors.amber
          )
      ),
      style: TextStyle(
          color: Colors.amber,
          fontSize: 25
      ),
    );
  }

  @override
  Widget build(BuildContext build){
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Conversor de Moedas \$'),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: FutureBuilder(
        future: getData(),
        builder: (context, snapshot){
          switch (snapshot.connectionState){
            case ConnectionState.waiting:
            case ConnectionState.none:
              return Center(
                child: Text('Carregando dados!', style: TextStyle(
                  color: Colors.amber,
                  fontSize: 25
                ), textAlign: TextAlign.center,),
              );
            default:
              if (snapshot.hasError){
                return Center(
                  child: Text('Erro ao carregar dados :(', style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25
                  ), textAlign: TextAlign.center,),
                );
              }
              else {
                model = snapshot.data;

                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(Icons.monetization_on, size: 150, color: Colors.amber),
                      _buildInput('Reais', 'R\$', _realController, _realChanged),
                      Divider(),
                      _buildInput('Dólar', 'U\$', _dollarController, _dollarChanged),
                      Divider(),
                      _buildInput('Euros', 'E\$', _euroController, _euroChanged),
                    ],
                  )
                );
              }
          }
        },
      )
    );
  }
}

Future<Model> getData() async{
  final response = await dio.get(url);
  double dollar = response.data['results']['currencies']['USD']['buy'];
  double euro = response.data['results']['currencies']['EUR']['buy'];
  double bitcoin = response.data['results']['currencies']['BTC']['buy'];

  Model model = Model();
  model.usd = dollar;
  model.euro = euro;
  model.bitcoin = bitcoin;
  return model;
}

class Model {
  double usd;
  double euro;
  double bitcoin;
}