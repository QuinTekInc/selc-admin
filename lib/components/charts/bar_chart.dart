
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CustomBarChart extends StatelessWidget {


  //stuff that will be needed.
  //chart title.
  //left axis title and the bar rods.
  //bottom axis title and the labels for bar rods.
  //left side title style.
  //bottom side title style.
  //the actual bar chart data in the form of a map.

  //rod colors iteself. [colors are applied to the first n rods according to the indices. default colors will be applied.]
  //rod background color.


  final String? chartTitle;
  final String? leftAxisTitle;
  final String? bottomAxisTitle;
  final ChartRotation rotation;
  
  final double? maxY;
  final double? minY;
  final List<CustomBarGroup>? groups;


  final Color? containerBackgroundColor;
  
  //text styles for the title.
  final TextStyle? titleStyle;
  final TextStyle? axisLabelStyle;
  final TextStyle? axisNameStyle;


  final double width;
  final double height;


  CustomBarChart({
    super.key, 
    this.chartTitle, 
    this.leftAxisTitle, 
    this.bottomAxisTitle,
    this.maxY,
    this.minY,
    this.groups,
    this.rotation = ChartRotation.upRight, //upright position.
    this.containerBackgroundColor,
    this.titleStyle,
    this.axisLabelStyle,
    this.axisNameStyle,
    this.width = 400,
    this.height = 400
  });



  final defaultLabelStyle = TextStyle(
    color: Colors.black45,
    fontWeight: FontWeight.w600,
    fontSize: 11
  );


  final defaultAxisStyle = TextStyle(
    color: Colors.black45,
    fontWeight: FontWeight.w600,
    fontSize: 16
  );


  @override
  Widget build(BuildContext context) {
    return Container(

      alignment: Alignment.center,

      width: width,
      height: height,

      padding: EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: containerBackgroundColor ?? Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12)
      ),


      child: Column(

        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [


          //todo: the title text for graph
          if(chartTitle != null) Text(
            chartTitle!,
            softWrap: true,
            textAlign: TextAlign.center,

            style: titleStyle ?? TextStyle(  
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black54
            ),
          ),


          const SizedBox(height: 12,),
          

          //todo: the bar chart itself.
          Expanded(
            flex: 2,


            child: BarChart(

              BarChartData(

                rotationQuarterTurns: rotation.value,

                minY: minY,
                maxY: maxY,

                barGroups: groups != null ? List<BarChartGroupData>.generate(
                  groups!.length, 
                  (index) => makeGroupedData(groups![index])
                ): [],

                titlesData: FlTitlesData(
                  show: true,

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

                    axisNameWidget: leftAxisTitle != null ? Text(
                      leftAxisTitle!,
                      style: axisNameStyle ?? defaultAxisStyle
                    ) : null,

                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta){

                        return SideTitleWidget(
                          meta: meta, 
                          child: Text(
                            value.toInt().toString(),
                            style: axisLabelStyle ?? defaultLabelStyle,
                          )
                        );
                      }
                    )
                  ),


                  bottomTitles: AxisTitles( 

                    axisNameWidget: bottomAxisTitle != null ? Text(
                      bottomAxisTitle!,
                      style: axisNameStyle ?? defaultAxisStyle,
                    ) : null,

                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta){                      

                        String label = '${value.toInt()}';

                        dynamic xLabel = groups!.where((group) => group.x == value.toInt()).toList().first.label;

                        if(xLabel != null){
                          label = xLabel;
                        }

                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            label,
                            style: axisLabelStyle ?? defaultLabelStyle,
                          )
                        );

                      }
                    ),
                    
                  )
                ),

                borderData: FlBorderData(  
                  show: false,
                ),


                
              ),
            ),
          ),


        ],
      ),
    );
  }


  //todo: for the bar chart rod.
  BarChartGroupData makeGroupedData(CustomBarGroup group){

    return BarChartGroupData(
      x: group.x, 
      barRods: List<BarChartRodData>.generate(
        group.rods.length,
        (int index) => BarChartRodData(
          toY: group.rods[index].y,
          width: 22,
          color: group.rods[index].rodColor ?? Colors.purple.shade700,
          borderRadius: BorderRadius.circular(16),
          // borderSide: BorderSide(  
          //   color: constants.primaryMaterialColor.shade200,
          //   width: 1.5
          // ),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 20, //set the background y to the maximum y value of the entire graph,
            color: Colors.grey.shade100
          )
        )
      )
    );
  }
}



enum ChartRotation{
  upRight(0),

  leftSideUp(1),

  upSideDown(2),

  right(3);


  final int value;

  const ChartRotation(this.value);
}



/*
  [
     
    group: {
      label: label for the current bar group.(bottom[x] axis rod group)
      rods: [
        {
          x: x value,
          y: y value
        }
      ]
    }
    
  ]
 
*/


class CustomBarGroup{

  int x;
  String? label;
  List<Rod> rods;

  CustomBarGroup({required this.x, required this.rods, this.label});

}

//the the rod is also the bar in the bar chart.
class Rod{

  double y;
  Color? rodColor;

  Rod({required this.y, this.rodColor});
}

