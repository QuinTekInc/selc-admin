

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';


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

  final double maxY;
  final double? maxX;
  final double minY;
  final double? minX;

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
    this.maxY = 20,
    this.maxX,
    this.minY = 0,
    this.minX = 0,
  });

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
            style: titleStyle ?? TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16
            ),
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
                      style: axisNameStyle ?? TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold
                      ),
                    ),

                    //todo: labels from the y axis.
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta){

                        return SideTitleWidget(
                          meta: meta,
                          child: Text(  
                            '${value.toInt()}',
                            style: axisLabelStyle ?? TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }
                    )
                  ),


                  //todo: labels for the x axis
                  bottomTitles: AxisTitles(
                    axisNameWidget: bottomAxisitle == null ? null : Text(  
                      bottomAxisitle!,
                      style: axisNameStyle ?? TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold
                      ),
                    ),

                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta){
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(  
                            '${value.toInt()}',
                            style: axisLabelStyle ?? TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }
                    )
                  ),

                ),

                gridData: FlGridData(
                  show: true
                ),

                borderData: FlBorderData(
                  show: false,
                  border: Border.all(  
                    width: 1,
                    color: Colors.black45
                  )
                )

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
      color: Colors.purple.shade700,

      dotData: FlDotData(
        show: true,
      ),
      belowBarData: BarAreaData(show: false),


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