

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../providers/pref_provider.dart';


class CustomLineChart extends StatelessWidget {


  final double width;
  final double height;


  final Color? containerBackgroundColor;

  final String? chartTitle;
  final String? leftAxisTitle;
  final String? bottomAxisitle;

  final List<CustomLineChartSpotData> spotData;


  final TextStyle? titleStyle;
  final TextStyle? axisLabelStyle;
  final TextStyle? axisNameStyle;

  final double? maxY;
  final double? maxX;
  final double minY;
  final double? minX;

  final showXLabels;
  final showYLabels;
  final showGrid;

  const CustomLineChart({
    super.key, 
    this.containerBackgroundColor,
    this.chartTitle, 
    this.leftAxisTitle, 
    this.bottomAxisitle, 
    this.spotData= const [],
    this.titleStyle,
    this.axisNameStyle,
    this.axisLabelStyle,
    this.width = 400,
    this.height = 400,
    this.maxY,
    this.maxX,
    this.minY = 0,
    this.minX = 0,
    this.showXLabels = true,
    this.showYLabels = false,
    this.showGrid = true
  });





  TextStyle _titleStyle(BuildContext context)  => TextStyle(
    color: PreferencesProvider.getColor(context, 'text-color'),
    fontWeight: FontWeight.bold,
    fontSize: 17,
    fontFamily: 'Poppins'
  );

  TextStyle _axisLabelStyle(BuildContext context) => TextStyle(
    color: PreferencesProvider.getColor(context,'placeholder-text-color'),
    fontFamily: 'Poppins',
  );


  TextStyle _axisNameStyle(BuildContext context) => TextStyle(
  color: PreferencesProvider.getColor(context,'text-color'),
  fontFamily: 'Poppins',
  fontWeight: FontWeight.w600
  );


  @override
  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.all(12),
      height: height,
      width: width,

      decoration: BoxDecoration(
        color: containerBackgroundColor ?? Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12)
      ),


      child: Column(

        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,

        children: [

          if(chartTitle != null) Text(
            chartTitle!,
            style: titleStyle ?? _titleStyle(context)
          ),

          const SizedBox(height: 12,),

          Expanded(
            flex: 2,
            child: LineChart(

              LineChartData(
                minX: minX,
                minY: minY,
                maxY: maxY,
                maxX: maxX,



                lineBarsData: [makeLineChartBarData()],

                titlesData: FlTitlesData(


                  topTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false
                    )
                  ),


                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false
                    )
                  ),


                  leftTitles: AxisTitles(

                    axisNameWidget: leftAxisTitle == null ? null : Text(  
                      leftAxisTitle!,
                      style: axisNameStyle ?? _axisNameStyle(context)
                    ),

                    //todo: labels from the y axis.
                    sideTitles: SideTitles(
                      showTitles: showYLabels,
                      interval: 1,
                      getTitlesWidget: (value, meta){

                        return SideTitleWidget(
                          meta: meta,
                          child: Text(  
                            '${value.toInt()}',
                            style: axisLabelStyle ?? _axisLabelStyle(context)
                          ),
                        );
                      }
                    )
                  ),


                  //todo: labels for the x axis
                  bottomTitles: AxisTitles(
                    axisNameWidget: bottomAxisitle == null ? null : Text(  
                      bottomAxisitle!,
                      style: axisNameStyle ?? _axisNameStyle(context)
                    ),

                    sideTitles: SideTitles(
                      showTitles: showXLabels,
                      interval: 1,
                      getTitlesWidget: (value, meta){
                        String label = '${value.toInt()}';

                        dynamic xLabel;


                        try{
                          xLabel = spotData.where((group) => group.x == value.toInt()).toList().first.label;
                        }on Exception catch(_){
                          xLabel = label;
                        }

                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            xLabel,
                            style: axisLabelStyle ?? _axisLabelStyle(context),
                          )
                        );
                      }
                    )
                  ),

                ),

                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(

                    tooltipBorder: BorderSide(color: Colors.green.shade400),
                    tooltipBorderRadius: BorderRadius.circular(12),

                    getTooltipColor: (touchedSpots) => PreferencesProvider.getColor(context, 'alt-primary-color-2', listen: false),

                    getTooltipItems: (touchedSpots){
                      return touchedSpots.map((spot){

                        int index = spot.x.toInt();

                        return LineTooltipItem(
                          spotData[index].label!,
                          TextStyle(
                            fontWeight: FontWeight.w600,
                            color: PreferencesProvider.getColor(context, 'text-color', listen: false)
                          )
                        );
                      }).toList();
                    }
                  )
                ),

                gridData: FlGridData(
                  show: showGrid
                ),

                borderData: FlBorderData(
                  show: false,
                  border: Border.all(  
                    width: 1,
                    color: Colors.black45
                  )
                ),


              )
            ),
          )
        ],
        
      ),
    );
  }



  LineChartBarData makeLineChartBarData(){

    return LineChartBarData(
      isStrokeCapRound: true,
      isCurved: true,
      barWidth: 3,
      color: Colors.green.shade600,

      dotData: FlDotData(
        show: true,
      ),
      belowBarData: BarAreaData(
      show: true,
      gradient: LinearGradient(
        colors: [Colors.green.shade400, Colors.blue.shade400]
            .map((color) => color.withValues(alpha: 0.3))
            .toList(),
      ),
    ),


      spots: List<FlSpot>.generate(
        spotData.length, 
        (int index) => FlSpot(spotData[index].x, spotData[index].y)
      )
    );
  }
}





class CustomLineChartSpotData{

  double x;
  String? label;
  double y;


  CustomLineChartSpotData({required this.x, required this.y, this.label});

}