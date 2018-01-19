function execute_start(){

    terminal_print('Program started');
    add_mem_id();

    if(ins == undefined){
    	ins = $('.instruction:first');
    	count = 1;
        output_temp = [];
    }

    $('.last_step').removeClass('last_step');
    $('.next_step').removeClass('next_step');
    $('.step_data').removeClass('step_data');

    while(ins!=undefined){
    	ins = execute(ins);
    	count++;
        if(count%5000==1){
            if(!confirm(count-1+" cycles executed, continue?")){
                terminal_dump_log();
                return;
            }
        }
    }
    
    terminal_dump_log();
    ins = undefined;
    count = 1;
    output_temp = [];
}
function step(){
    add_mem_id();
    count = 1;
    output_temp = [];
    $('.instruction:first').addClass('next_step');
    ins = $('.instruction:first');
}
function execute_step(){
	if(ins == undefined){
		if(confirm('Start step execution?')){
			step();
		}
	}else{
		$('.last_step').removeClass('last_step');
    	$('.next_step').removeClass('next_step').addClass('last_step');
    	$('.step_data').removeClass('step_data');
		ins = execute(ins, true);
		count ++;
		if(ins==undefined){
			count = 1;
            output_temp = [];
		}else{
            $(ins).addClass('next_step');
        }
		// if step, color
		terminal_dump_log();

	}
}

function execute_till_breakpoint(){
    if(ins == undefined){
        add_mem_id();
        ins = $('.instruction:first');
        count = 1;
        output_temp = [];
    }else{
        $('.next_step').removeClass('next_step');
    }
    while(true){
        $('.last_step').removeClass('last_step');
        $('.step_data').removeClass('step_data');
        $(ins).addClass('last_step');
        ins = execute(ins,true);
        count++;
        if(ins==undefined){
            terminal_dump_log();
            count = 1;
            output_temp = [];
            break;
        }
        if($(ins).hasClass('step_break_point')){
            $(ins).addClass('next_step');
            terminal_dump_log();
            break;
        }
    }

}
var log = [];
var count = 1;
var ins = undefined;
var output_temp = [];
function execute(ins, step = false){
	/// check if ins exsists
	if(ins.length<=0){
		log.push('>   Error! Please check your log');
		//terminal_warning('Error','danger');
		return;
	}
    /*
	if(count%5000==0){
        if(!confirm('continue? '+count+ 'cycles already')){
            terminal_print('terminated by user');
            return;
        }
    }*/
	/// program memory and data from memory
	var mem = new Array();
    var data = new Array();

    /// indirect_addr is true when using '&' which is the address of a label
    ///   when direct_addr is true, the result will be an direct address
    var indirect_addr = false;

    var constant = false;
    
    $(ins).find('.prog').each(function (){
        mem.push($(this).html());
    });
    if(mem.length!=4){
    	log.push('>   Error! Program operand error');
    	//terminal_warning('Error','danger');
		return;
    }

    /// for mem[0~2], read the data
    for(var i = 0; i < 3; i++){
    	/// If first letter is @, then read the data by data-mem_id attribute
	    if(mem[i][0]=='@'){
	    	/// direct address
	    	if($('#M'+mem[i].substring(1)).length==0){
	    		terminal_warning('warning: data '+mem[i]+' not found','danger');
	    		return;
	    	}
	        data[i] = $('#M'+mem[i].substring(1)).text();
            if(step){
                $('#M'+mem[i].substring(1)).addClass('step_data');
            }
	    }else{
	    	/// indirect address, using labels, which is normal
	    	if($('.label_'+mem[i].replace(/%/g,'\\%')).length==0){
            	terminal_warning('warning: data '+mem[i]+' not found, created one with value 0','warning');
            	$('#data-mem').append(
            			'<div class="data-line row bg-warning"><div class="label-data col-xs-3"><span class="label label-default data-label">'+mem[i]+'</span></div><div class="former-data col-xs-3">(0)</div><div class="data-data col-xs-5"><span class="data label_'+mem[i]+'">0</span></div><a class="btn btn-default edit"><span class="glyphicon glyphicon-edit" aria-hidden="true"></span></a></div>');
        	}
	    	data[i] = $('.label_'+mem[i].replace(/%/g,'\\%')).text();
            if(step){
                $('.label_'+mem[i].replace(/%/g,'\\%')).addClass('step_data');
            }
	    }
        /// If the data read is a indirect_address,
        ///   which is started with '&'
        ///   change it into value
        /// If data is a calculated address, make it a normal integer
	    if(data[i][0]=='&'){
	        data[i] = $('.label_'+data[i].substring(1).replace(/%/g,'\\%')).attr('id').substring(1);
	        if(i!=2){
                indirect_addr = true;
            }
	    }else if(data[i][0]=='@'){
	    	data[i] = data[i].substring(1);
	    	if(i!=2){
                indirect_addr = true;
            }
	    }else if(data[i][0]=='$'){
            data[i] = data[i].substring(1);
            if(i == 2){
                constant = true;
            }
        }
    }

    /**/
    /// Calculate the result
    if($(ins).find('.extend').length!=0){
        data[3] = ((data[1]>>>0)<(data[0]>>>0)?0x80000000:0)|(((data[1]&data[0])>>1)&0x7fffffff);
    }else{
        data[3] = (data[1] - data[0])&0xffffffff;
    }


    /// log
    log.push('>>> Cycle: '+count+'    PC: '+$(ins).find('.prog').first().attr('id').substring(1));
    log.push('    Instruction: [0]:'+mem[0]+' [1]:'+mem[1]+' [2]: '+mem[2]+' [3]: '+mem[3]);
    log.push('    Data:        ['+mem[0]+']:'+data[0]);
    log.push('                 ['+mem[1]+']:'+data[1]);
    log.push('                 ['+mem[2]+']:'+data[2]);
    log.push('    Result:      '+data[3]);

    if($(ins).find('.output').length!=0){
        var out = $(ins).find('.output').text().replace(/^>>>/,"");
        out = out
                .replace(/\$\(\)|\$\{\}|\$\(res\)/g,data[3])
                .replace(/\$\(1\)|\$\{1\}/g,data[0])
                .replace(/\$\(2\)|\$\{2\}/g,data[1])
                .replace(/\$\(3\)|\$\{3\}/g,data[2])
                .replace(/\$\{cycle(\(\))?\}|\$\(cycle\)/ig,count)
                .replace(/\$\{pc(\(\))?\}|\$\(pc\)/ig,$(ins).find('.prog').first().attr('id').substring(1))
                /*.replace(/\$\{count\(\s*(\S*?)\s*\)\}/ig,function(){
                    var args = arguments;
                    //console.log(args);
                    if(output_temp[args[1]]==undefined){
                        output_temp[args[1]] = 1;
                    }
                    return output_temp[args[1]]++;
                })
                .replace(/\$\{num\(\s*(\S*?)\s*\)\}/ig,function(){
                    var args = arguments;
                    //console.log(args);
                    if(output_temp[args[1]]==undefined){
                        output_temp[args[1]] = 1;
                    }
                    return output_temp[args[1]];
                })
                .replace(/\$\{clear\(\s*(\S*?)\s*\)\}/ig,function(){
                    var args = arguments;
                    //console.log(args);
                    output_temp[args[1]] = undefined;
                    return "";
                })*/
                .replace(/\$\{count\(\s*(\S*?)\s*\)\}|\$\{num\(\s*(\S*?)\s*\)\}|\$\{clear\(\s*(\S*?)\s*\)\}/ig,function(){
                    var args = arguments;
                    //console.log(args);
                    if(args[1]!=undefined){
                        if(output_temp[args[1]]==undefined){
                            output_temp[args[1]] = 1;
                        }
                        return output_temp[args[1]]++;
                    }
                    if(args[2]!=undefined){
                        if(output_temp[args[2]]==undefined){
                            output_temp[args[2]] = 1;
                        }
                        return output_temp[args[2]];
                    }
                    if(args[3]!=undefined){
                        output_temp[args[3]] = undefined;
                        return "";
                    }
                    return "";
                })
                .replace(/\$\{label\(\s*(\S*?)\s*\)\}/g,function(){
                    var args = arguments;
                    //console.log(args);
                    return $('.label_'+args[1]).text();
                })
                .replace(/\\n/g,"\n");
        $("#output").append(html(out));
        $('#output').scrollTop( $('#output')[0].scrollHeight );
    }
    if(constant){
        if(data[3]!=data[2]){
            log.push('>>> program intended to overwrite constant "'+mem[2]+'" !!');
            //terminal_warning('program intended to overwrite constant "'+mem[2]+'" !!','danger');
            return;
        }
    }

    /// Write the result to address:mem[2]
    if(indirect_addr){
        if(mem[2][0]=='@'){
            $('#M'+mem[2].substring(1)).html('@'+data[3]);
        }else{
            $('.label_'+mem[2].replace(/%/g,'\\%')).html('@'+data[3]);
        }
    }else{
        if(mem[2][0]=='@'){
            $('#M'+mem[2].substring(1)).html(data[3]);
        }else{
            $('.label_'+mem[2].replace(/%/g,'\\%')).html(data[3]);
        }
    }


    if(mem[3]==undefined){
        //console.log('failed');
        //terminal_print('failed');
        log.push('failed');
        terminal_warning('failed: Undefined label','danger');
        return;
    }

    /// Branch if negtive
    if($(ins).find('.extend').length!=0){
        if(mem[3]!='NEXT' && (data[1] & data[0] & 1) == 0){
            if(/*mem[3]=='@0'||*/mem[3]=='@-1'||mem[3]=='HALT'){
                //console.log('finished !');
                log.push('>>> Excution finished! Total cycles: '+count);
                return;
            }
            if(mem[3][0]=='@'){
                //execute($('[data-mem_id = "'+mem[3].substring(1)+'"]').parent().parent(),count+1,step_break);
                return $('#M'+mem[3].substring(1)).parent().parent();
            }else{
                mem[3] = mem[3].replace(/%/g,'\\%');
                //execute($('.label_'+mem[3]).parent().parent(),count+1,step_break);
                return $('.label_'+mem[3]).parent().parent();
            }
            
        }else{
            //execute($(ins).next(),count+1,step_break);
            return $(ins).next();
        }
    }
	if(mem[3]!='NEXT'&&data[3]<0){
        if(/*mem[3]=='@0'||*/mem[3]=='@-1'||mem[3]=='HALT'){
            //console.log('finished !');
            log.push('>>> Excution finished! Total cycles: '+count);
            return;
        }
        if(mem[3][0]=='@'){
            //execute($('[data-mem_id = "'+mem[3].substring(1)+'"]').parent().parent(),count+1,step_break);
            return $('#M'+mem[3].substring(1)).parent().parent();
        }else{
            mem[3] = mem[3].replace(/%/g,'\\%');
            //execute($('.label_'+mem[3]).parent().parent(),count+1,step_break);
            return $('.label_'+mem[3]).parent().parent();
        }
        
    }else{
        //execute($(ins).next(),count+1,step_break);
        return $(ins).next();
    }

}
function terminal_dump_log(){
    if(log.length>0){
    	$('#terminal').append(html(log.join("\n"))+'<br>');
    	log = [];
    }
    $('#terminal').scrollTop( $('#terminal')[0].scrollHeight );
}
function terminal_print(str){
	$('#terminal').append(html('>>> '+str+'\n'));
    $('#terminal').scrollTop( $('#terminal')[0].scrollHeight );
}
function html(s){
    if (s.length == 0) return "";
    s = s.replace(/>/g, "&gt;")
            .replace(/</g, "&lt;")
            .replace(/ /g, "&nbsp;")
            .replace(/\n/g, "<br>");
    return s;
}
var splitter = '<|>';
var output = [];
var allocate = [];
function parse_text(){
    var text_data = editor.getValue();
    allocate = [];
    //terminal_print(text_data);
    //terminal_print('<pre>'+text_data+'</pre>');
    raw_mem = text_data
                    .replace(/#\{\s*(\d*)\s*,\s*(\S*?)\s*,\s*(\S*?)\s*\}#/g,function(){
                        var args = arguments;
                        console.log("test mode");
                        allocate.push([args[1],args[2],args[3]]);
                        return "";
                    })
                    .replace(/\/\*[\s\S]*?\*\/|\/\/.*|\r/g,"") // remove '/**/','//','\r'
                    .replace(/^\s*|[ \t\v]*$/mg,"").replace(/\s*$/,""); // remove empty row
                    //.replace(/^\s+|\s+$/mg,"") // remove spaces in front of or behind a row
    var c = 0
    output = raw_mem.match(/>>>[\s\S]*?$/mg);
    //console.log(output);
    raw_mem = raw_mem
                    .replace(/\s*>>>[\s\S]*?$/mg,function(){return "$>>>"+c+++">";})
                    .replace(/\s*:\s*/g,":")
                    .replace(/!!!\s*/g,"!!!")
                    .replace(/\[\s*(\S+?)\s*\]/g,"[$1]")
                    .replace(/\s*,\s*|[ \t\v]+/g,",")
                    .split('\n')
    
    terminal_print('Starting to parse raw data to memory');
    prog_mem = [],data_mem = [];
    var domain = [];
    for(var key in raw_mem){
        var pop = false;
        var ins = raw_mem[key];
        if(ins.indexOf("!!!")>=0){
            ins = ins.replace(/!!!/,"");
            prog_mem.push('BREAK_POINT');
        }
        while(ins.indexOf("%{")==0){
        	var parse = ins.match(/\%\{\s*\[\s*(\S.*?)\s*\]\s*/);
        	domain.push(parse[1]);
            if(parse[1].indexOf(',')>=0){
                alert('error');
                terminal_warning("namespace error","danger");
                return;
            }
        	ins = ins.replace(/\%\{\s*\[\s*(\S.*?)\s*\]\s*/,"");
        }
        while(ins.indexOf("}%")>=0){
        	ins = ins.replace(/\s*\}\%\s*/,"");
            if(ins.length!=0){
                pop = true;
            }else{
                domain.pop();
            }
        }
        if(ins.length==0){
            continue;
        }
        var out_message = undefined;
        if(ins.indexOf('$>>>')>=0){
            ins = ins.replace(/\$>>>(\d*)>/g,function(){
                var args = arguments;
                //console.log(args);
                if(out_message==undefined){
                    out_message = [args[1]];
                }else{
                    out_message.push(args[1]);
                }
                return "";
            });
        }
        //console.log(out_message);
        var extend = false;
        var split0 = ins.replace(",EXTEND",function(){
            extend = true;
            return "";
        });
        split0 = split0.split(',');
        var split = {};
        if(domain.length>0){
            for(var i = 0; i < split0.length; i++){
                /*if(split[i][0]=="'"){
                    //
                    console.log('not ready');
                }else */
                if(split0[i][0]!='@'&&spli0t[i]!='NEXT'&&split0[i]!='HALT'){
                    split[i] = domain.concat([splitter+split0[i]]).join("%");
                }else{
                    split[i] = split0[i];
                }
            }
            
        }else{
            for(var i = 0; i < split0.length; i++){
                split[i] = split0[i];
            }
        }
        if(extend==true){
            split['extend'] = true;
        }
        if(split0.length==4){
            if(out_message!=undefined){
                split['out']=out_message;
            }
        	prog_mem.push(split);
        }else if(split0.length==3){
            split[3]='NEXT';
            if(out_message!=undefined){
                split['out']=out_message;
            }
            prog_mem.push(split);
        }else if(split0.length==1){
            data_mem.push(split[0]);
        }else{
            alert('error');
            terminal_print('Error occured');
            return;
        }

        if(pop){
            domain.pop();
        }
    }
    //terminal_print('********************');
    //terminal_print_array_array(prog_mem);
    //terminal_print_array(data_mem);
    //terminal_print('********************');
    //terminal_print('Parsing finished');
    create_memory();
    
}

function create_memory(){
    //clear former running data
    ins = undefined;
    //insert area
    $('#memory').html('<div class="data-mem col-sm-5" id="data-mem"></div><div class="routine col-sm-7" id="routine"></div>');
    //create routine memory
    var break_point = false;
    for(var key in prog_mem){
        
        if(prog_mem[key]=='BREAK_POINT'){
            break_point = true;
            continue;
        }
        var code;
        if(break_point){
            code = '<div class="instruction row step_break_point">';
            break_point = false;
        }else{
            code = '<div class="instruction row">';
        }
        for(var i = 0; i < 4; i++){
            code += '<div class="col-xs-3">'

            var split_domain = prog_mem[key][i].split(splitter);
            var split = split_domain[split_domain.length-1].split(':');
            if(split_domain.length==2){
                for(var j = 0; j < split.length; j++){
                    if(split[j][0] == '"'){
                        split[j] = split[j].substring(1);
                    }else if(split[j][0]=="'"){
                        var domain = split_domain[0].split("%");
                        console.log(domain);
                        split[j] = domain.slice(0,-1-split[j].match(/'/g).length).concat([split[j].replace(/\s*'\s*/g,"")]).join('%');
                        console.log(split[j]);
                    }else if(split[j][0]=='@' || split[j]=='NEXT' || split[j]=='HALT'){
                        //do nothing
                    }else{
                        split[j] = split_domain[0] + split[j];
                    }
                }
            }else{
                for(var j = 0; j < split.length; j++){
                    if(split[j][0] == '"'){
                        split[j] = split[j].substring(1);
                    }else if(split[j][0] == "'"){
                        split[j] = split[j].replace(/\s*'\s*/g,"");
                    }
                }
            }
            
            for(var j = 0; j < split.length-1; j++){
                code += '<span class="label label-default">'+split[j]+'</span>';
            }
            code += '<span class="prog';
            for(var j = 0; j < split.length-1; j++){
                code += ' label_'+split[j];
            }
            code += '">' + split[split.length-1] + '</span>';
            code += '</div>';
        }
        if(prog_mem[key]['out']!=undefined){
            code+='<div class="output">&gt;&gt;&gt;';
            for (var k in prog_mem[key]['out']){
                code += output[prog_mem[key]['out'][k]].substring(3);
            }

            code+='</div>';
        }
        if(prog_mem[key]['extend']==true){
            code+='<div class="extend">EX</div>';
        }
        code += '</div>'
        $('#routine').append(code);
    }
    for(var key in data_mem){
        var split_domain = data_mem[key].split(splitter);
        var split = split_domain[split_domain.length-1].split(':');
        if(split_domain.length==2){
            for(var i = 0; i < split.length-1; i++){
                if(split[i][0]=='"'){
                    split[i] = split[i].substring(1);
                }else if(true){////////////////////////////////////////
                    split[i] = split_domain[0] + split[i];
                }else{

                }
            }
            if(split[split.length-1][0]=='&'){
                split[split.length-1] = '&'+split_domain[0]+split[split.length-1].substring(1);
            }
        }else{
            for(var i = 0; i < split.length-1; i++){
                if(split[i][0] == '"'){
                    split[i] = split[i].substring(1);
                }
            }
        }

        var code = '<div class="data-line row"><div class="label-data col-xs-3">';
        for(var i = 0; i < split.length-1; i++){
            code += '<span class="label label-default data-label">'+split[i]+'</span>';
        }
        code += '</div>';
        code += '<div class="former-data col-xs-3">('+split[split.length-1]+')</div><div class="data-data col-xs-5"><span class="data';
        for(var i = 0; i < split.length-1; i++){
            code += ' label_'+split[i];
        }
        code += '">'+split[split.length-1]+'</span></div></div>';
        
        $('#data-mem').append(code);
    }
    for(var key in allocate){
        var code = '<div style="display:none">';
        code += '<span class="data label_'+allocate[key][1]+'">0</span>';
        for(var i = 1; i < allocate[key][0]-1; i++){
            code += '<span class="data">0</span>';
        }
        code += '<span class="data label_'+allocate[key][2]+'">0</span></div>';
        $('#data-mem').append(code);
    }
    //$('.instruction').append('<a class="btn btn-default edit edit-routine"><span class="glyphicon glyphicon-edit" aria-hidden="true"></span></a>');
    $('.data-line').append('<a class="btn btn-default edit edit-data"><span class="glyphicon glyphicon-edit" aria-hidden="true"></span></a>');
    $('.edit-data').click(edit_data);
}

function add_mem_id(){
    terminal_print('Adding memory address to all data');
    var count = 0;
    $('.prog').each(function(){
        $(this).attr('id',"M"+count++);
    });
    $('.data').each(function(){
        $(this).attr('id',"M"+count++);
    });
    //console.log(count);
    
    terminal_print('Totally '+count+' words of memory used.');
}



function save_edit(){
    var data = $('#input-data').val();
    var label = $('#input-label').val();
    
    var obj = $('#myModal').data('edit');
    var split = label.split(':');
    var label_data = '';
    for(var i = 0; i < split.length; i++){
        label_data += '<span class="label label-default data-label">'+split[i]+'</span>';
    }
    $(obj).find('.label-data').html(label_data);
    $(obj).find('.data').text(data);
    var class_data = 'data';
    for(var i = 0; i < split.length; i++){
        class_data += ' label_'+split[i];
    }
    $(obj).find('.data').attr('class',class_data);
    /*
    var code = '<div class="data-line row"><div class="label-data col-xs-3">';
        for(var i = 0; i < split.length-1; i++){
            code += '<span class="label label-default data-label">'+split[i]+'</span>';
        }
        code += '</div>';
        code += '<div class="former-data col-xs-3">('+split[split.length-1]+')</div><div class="data-data col-xs-5"><span class="data';
        for(var i = 0; i < split.length-1; i++){
            code += ' label_'+split[i];
        }
        code += '">'+split[split.length-1]+'</span></div></div>';



    if(split.length==1){
        $(obj).find('.data').replaceWith('<span class="data" id="label_'+label+'">'+data+'</span>');
        $(obj).find('.label-data').replaceWith('<div class="label-data col-xs-3"><span class="label label-default data-label">'+label+'</span></div>');
    }else{
        alert('not done');
        //$(obj).find('.data')
    }*/
    
    $('#myModal').modal('hide');
}
function terminal_clear(){
    $('#terminal').html('');
}
function terminal_warning(str,type='warning'){
    $('#warning').append('<div class="alert alert-dismissible alert-'+type+'">'+str+'<a href="#" class="close" data-dismiss="alert">&times;</a></div>');
    //$('.alert').alert();
}
function write_words(){
    add_mem_id();
    var mem = new Array();
    var count=0;
    $('.prog').each(function(){
        var d = $(this).text().replace(/%/g,'\\%');

        if(d=='NEXT'){
            mem[count++] = parseInt($(this).attr('id').substring(1))+1;
        }else if(d=='HALT'){
            mem[count++] = -1;//$(this).html().replace('#','');
        //}else if($(this).html()[0]=='#'){
        //    mem[count++] = $('.label_'+$(this).html().substring(1));
        }else if(d[0]=='@'){
            mem[count++] = d.substring(1);
        }else{
            mem[count++] = $('.label_'+d).attr('id').substring(1);
        }
    });
    $('.data').each(function(){
        var d = $(this).text().replace(/%/g,'\\%');
        if(d[0]=='&'){
            mem[count++] = $('.label_'+d.substring(1)).attr('id').substring(1);
        }else if(d[0]=='$'){
            mem[count++] = d.substring(1);
        }else{
            mem[count++] = d;
        }
    });
    //print_log(mem,'memory');
    //print_machine_with_num(mem);
    if($('#output-data').val()==''||confirm('clear former data?')){
        //$('#machine').html('');
        var output = '';
        for(var key in mem){
            //$('#machine').append(mem[key]+'<br>');
            output += mem[key]+'\n';
        }
        $('#output-data').val(output);
    }
}
function check_routine(){
    terminal_print('Checking routine memory');
    $('.prog').each(function(){
        var addr = $(this).html();
        if(addr=='HALT'||addr=="NEXT"){
            return;
        }
        var found = $('.label_'+addr).length;
        if(found==0){
            terminal_warning('label '+addr+' not found');
        }else if(found>1){
            terminal_warning('label '+ addr + ' repeated '+found+' times');
        }
    });
    terminal_print('finished');
}
function add_load_list(name){
    $('#load-list').prepend('<li><a class="file-name" id="load_file_'+name+'">'+name+'</a><a class="file-delete" id="delete_file_'+name+'"><i class="glyphicon glyphicon-remove text-danger"></i></a></li>');
    $('#load_file_'+name).click(function(){
        load_text_data(name);
    })
    $('#delete_file_'+name).click(function(){
        delete_text_data(name);
    })
    
}
function edit_data(){
    $('#myModal').modal();
    var editing = $(this).parent()
    console.log(this);
    $('#input-data').val($(editing).find('.data').html());
    var label = $(editing).find('.data-label');
    if(label.length==1){
        $('#input-label').val($(label).html());
    }else{
        var labels = '';
        $(label).each(function(){
            labels += $(this).html()+':';
        });
        $('#input-label').val(labels.slice(0,-1));
    }
    //
    
    $('#myModal').data('edit',editing);
}

function save_text_data(name,data){
    
    //console.log(text_data);
    if(text_data.hasOwnProperty('(save)'+name)){
        if(confirm('This will overwrite the former data, continue?')){
            text_data['(save)'+name] = data;
            localStorage['text-data'] = JSON.stringify(text_data);
        }
    }else{
        text_data['(save)'+name] = data;
        //console.log(text_data);
        localStorage['text-data'] = JSON.stringify(text_data);
        add_load_list(name);
    }
}
function load_text_data(name){
    if(text_data.hasOwnProperty('(save)'+name)){
        editor.setValue(text_data['(save)'+name]);
        $('#current-editing').html(name);
    }else{
        alert(name + ' not found');
    }
}
function execute_words(mem){
    var pc = 0, cycles = 0;
    
    while(cycles<5000){
        cycles++;
        mem[mem[pc+2]] = (mem[mem[pc+1]] - mem[mem[pc]])&0xffffffff;
        if(mem[mem[pc+2]]<0){
            pc = mem[pc+3];
            if(pc==-1||pc==0){
                break;
            }
        }else{
            pc += 4;
        }
    }
    
    terminal_print('words excuted in '+cycles+' cycles');
    
}
function execute_memory_data(){
    var mem = $('#output-data').val().split('\n');
    for(var key in mem){
        mem[key] = parseInt(mem[key]);
    }
    console.log(mem);
    execute_words(mem);
}