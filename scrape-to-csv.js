function DownloadJSON2CSV(objArray) {
  
    var array = typeof objArray != 'object' ? JSON.parse(objArray) : objArray;

    var str = '';
    var headers = '';
    for (var i = 0; i < array.length; i++) {
      
        var line = '';
        for (var index in array[i]) {
          
          if (i == 0) {
             headers += '"' + index + '",'
          }

          if(line != '') line += ','
         
            line += '"'+array[i][index]+'"';
        }
 
        str += line + '\n';
    }
  
    window.open('data:text/csv;charset=utf-8,' + escape(headers + '\n' + str));
}

var cursor=0;
var dump={};
var result=[];

$('.bodycopy').children().each(function (i) { 
  
  if ($(this).attr('class') == 'slides') {
    if (dump['0 Name:'] != null) {
      result[result.length] = dump
      //console.log(dump);
      dump = {};
    }

    cursor=1;
  }
    
  if (cursor > 0) {
    if ($(this).prop("tagName") == "H2") {
      dump['0 Name:'] = $('a',$(this)).text();
      dump['1 Location:'] = $(this).contents().get(2).nodeValue.replace(/^, /,'');
      dump['2 Website:'] = $('a',$(this)).attr('href');

    } else if ($(this).prop("tagName") == "UL") {
      //console.log('skipping');
      
    } else {
      label = $('strong',$(this)).text();
      if (label != "" && $(this).contents().length > 1) {
        value = $(this).contents().get(1).nodeValue.trim();
        dump[ (cursor+1) + " " + label] = value;
      }
    }
    cursor++;
  }
 
});

DownloadJSON2CSV(result);