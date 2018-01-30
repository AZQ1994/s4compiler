import React, { Component } from 'react';
import logo from './logo.svg';
import './App.css';
import $ from "jquery";
import brace from 'brace';
import AceEditor from 'react-ace';

import 'brace/mode/java';
import 'brace/theme/github';

var text;
var allocate;
var output;
var prog_mem;
var data_mem;

var mem = [];
var label;
var data_mem_start_address = 0;
var hidden_start_address = 0;
function terminal_warning(){
  return//todo
}
let splitter = "<|>";
let editor = null;
function parse(){
    //text = editor.getValue()
    text = editor.getValue()
    allocate = [];

    let raw_mem = text
                    .replace(/#\{\s*(\d*)\s*,\s*(\S*?)\s*,\s*(\S*?)\s*\}#/g,function(){
                        var args = arguments;
                        console.log("test mode");
                        allocate.push([args[1],args[2],args[3]]);
                        return "";
                    })
                    .replace(/\/\*[\s\S]*?\*\/|\/\/.*|\r/g,"") // remove '/**/','//','\r'
                    .replace(/^\s*|[ \t\v]*$/mg,"").replace(/\s*$/,""); // remove empty row
                    //.replace(/^\s+|\s+$/mg,"") // remove spaces in front of or behind a row
    var c = 0;
    output = raw_mem.match(/>>>[\s\S]*?$/mg);
    //console.log(output);
    raw_mem = raw_mem
                    .replace(/\s*>>>[\s\S]*?$/mg,function(){return "$>>>"+c+++">";})
                    .replace(/\s*:\s*/g,":")
                    .replace(/!!!\s*/g,"!!!")
                    .replace(/\[\s*(\S+?)\s*\]/g,"[$1]")
                    .replace(/\s*,\s*|[ \t\v]+/g,",")
                    .split('\n')
    
    
    prog_mem = [],data_mem = [];
    var domain = [];
    for(var key in raw_mem){
        var pop = false;
        var ins = raw_mem[key];
        if(ins.indexOf("!!!")>=0){
            ins = ins.replace(/!!!/,"");
            prog_mem.push('BREAK_POINT');
        }
        while(ins.indexOf("%{")===0){
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
        if(ins.length===0){
            continue;
        }
        var out_message = undefined;
        if(ins.indexOf('$>>>')>=0){
            ins = ins.replace(/\$>>>(\d*)>/g,function(){
                var args = arguments;
                //console.log(args);
                if(out_message===undefined){
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
            for(let i = 0; i < split0.length; i++){
                /*if(split[i][0]==="'"){
                    //
                    console.log('not ready');
                }else */
                if(split0[i][0]!='@'&&split0[i]!='NEXT'&&split0[i]!='HALT'){
                    split[i] = domain.concat([splitter+split0[i]]).join("%");
                }else{
                    split[i] = split0[i];
                }
            }
            
        }else{
            for(let i = 0; i < split0.length; i++){
                split[i] = split0[i];
            }
        }
        if(extend===true){
            split['extend'] = true;
        }
        if(split0.length===4){
            if(out_message!=undefined){
                split['out']=out_message;
            }
            prog_mem.push(split);
        }else if(split0.length===3){
            split[3]='NEXT';
            if(out_message!=undefined){
                split['out']=out_message;
            }
            prog_mem.push(split);
        }else if(split0.length===1){
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
    mem = [];
    label = {};
    for (let i in prog_mem){
        for(let j = 0; j < 4; j++){
            if (typeof(prog_mem[i][j]) != "string"){
              console.log(prog_mem[i], prog_mem[i][j])
              // for debugging
            }
            let split = prog_mem[i][j].split(":");
            let index = mem.length;
            let l = split.slice(0,-1)
            let d = split[split.length-1];
            mem.push({"label":l,"data":d,"type":"normal","former":d});
            for (let x in l){
                label[l[x]] = index;
            }
        }
        if(prog_mem[i]["out"]!=null){
          // output
        }
    }
    data_mem_start_address = mem.length;
    for(let i in data_mem){
        let split = data_mem[i].split(":");
        let index = mem.length;
        let l = split.slice(0,-1)
        let d = split[split.length-1]
        mem.push({"label":l,"data":d,"type":"normal","former":d});
        for (let x in l){
            label[l[x]] = index;
        }
    }
    console.log(allocate);
    hidden_start_address = mem.length
    for(let i in allocate){
      let index = mem.length
      mem.push({"label":[allocate[i][1]],"data":allocate[i][2],"type":"hidden","former":allocate[i][2]})
      label[allocate[i][1]] = index
      for (let j = 1; j < allocate[i][0]; j++){
        mem.push({"label":[],"data":allocate[i][2],"type":"hidden","former":allocate[i][2]})
      }
    }
    console.log(mem, label);
    r()
    r2()
}

function test_print(){
    let  text = "";
    for(let i in mem){
        for(let l in mem[i]["label"]){
            text += mem[i]["label"][l] + ":"
        }
        text += mem[i]["data"]+"    ";
        if (i < data_mem_start_address){
            if(i%4===3){
                text += "<br>";
            }
        }else{
            text += "<br>";
        }
    }

    $("body").append(text);
}

function execute_prototype(){
    let pc = 0;

    while(pc != -1){
        let a = mem[pc];
        let b = mem[pc+1];
        let c = mem[pc+2];
        let d = mem[pc+3];
        
        let data_a = mem[label[a["data"]]];
        let data_b = mem[label[b["data"]]];
        
        let res = parseInt(data_b["data"])-parseInt(data_a["data"])&0xffffffff;
        mem[label[c["data"]]]["data"] = res
        console.log(pc,a,b,c,d,data_a,data_b,res);
        if(res < 0){
            
            if(d["data"] === "HALT"){
                break;
            }else if(d["data"] === "NEXT"){
                pc += 4;
            }else{
                pc = label[d["data"]];
            }
        }else{
            pc += 4;
        }
    }
}
function execute(){
    let pc = 0;
    let count = 0;
    
    var start = new Date().getTime();//起始时间
 
    while(pc != -1){
        pc = execute_one(pc, ++count);
    }
    log('>>> Excution finished! Total cycles: '+count);
    var mid = new Date().getTime();//接受时间
    log_flush();
    var end = new Date().getTime();//接受时间
    console.log((mid - start) + "ms" + (end - start)+"ms")
    r()
    r2()
}
function set_mem(a, res){
  if ( typeof(a) === "number" ){
    mem[a]["data"] = res
    return;
  }else if(typeof(a["data"])==="number"){
    mem[a["data"]]["data"] = res
    return
  }else if (a["data"][0]==='@') {
    mem[parseInt(a["data"].substring(1))]["data"] = res
    return 
  }else if (a["data"][0]==='&'){
    //error
    console.log("error?")
    return null
  }
  mem[label[a["data"]]]["data"] = res
  return;
}
function get_mem(a){//TODO
  if ( typeof(a) === "number" ){
    return mem[a];
  }else if(typeof(a["data"])==="number"){
    return mem[a["data"]]
  }else if (a["data"][0]==='@') {
    return mem[parseInt(a["data"].substring(1))]
  }else if (a["data"][0]==='&'){
    //error
    console.log("error?")
    return null
  }
  return mem[label[a["data"]]];
}
function get_int(a){
  let d = a["data"]
  if ( typeof(d) === "number" ){
    return d;
  }else if(typeof(d) != "string"){
    console.log("error",a);

    return null;
  }
  if (d[0]==='@'){
    return parseInt(d.substring(1))
  }else if(d[0] === '&'){
    return label[d.substring(1)]
  }else{
    return parseInt(d)
  }
}
function execute_one(pc, count){

    if(pc === -1){
        return pc;
    }
    let a = get_mem(pc);
    let b = get_mem(pc+1);
    let c = get_mem(pc+2);
    let d = get_mem(pc+3);
    
    let data_a = get_mem(a);
    let data_b = get_mem(b);
    let data_c = get_mem(c);

    let int_a = get_int(data_a)
    let int_b = get_int(data_b)
    
    let res = int_b-int_a&0xffffffff;
    set_mem(c, res)
    //console.log(pc,a,b,c,d,data_a,data_b,res);
    let next_pc = pc;
    if(res < 0){
        
        if(d["data"] === "HALT"){
            next_pc = -1;
        }else if(d["data"] === "NEXT"){
            next_pc += 4;
        }else if(typeof(d["data"]) === "number"){
          next_pc = d["data"]
        } else {
            next_pc = label[d["data"]]
        }
    }else{
        next_pc += 4;
    }
    /*log('>>> Cycle: '+count+'    PC: '+pc+'    next: '+next_pc);
    log('    Instruction: [0]:'+a["data"]+' [1]:'+b["data"]+' [2]: '+c["data"]+' [3]: '+d["data"]);
    log('    Data:        ['+a["data"]+']:'+data_a["data"]);
    log('                 ['+b["data"]+']:'+data_b["data"]);
    log('                 ['+c["data"]+']:'+data_c["data"]);
    log('    Result:      '+res);*/
    return next_pc;
}

var log_buf = [];
function log(str){
    log_buf.push(escape_space(str));
}
var log_flush;
function terminal_print(str){
  log(str);
  log_flush();
}
/*
The data we need !

mem = [
    0: [ label:[xxx], data:yyy ], 
    1: [ label:[xxx], data:yyy ], 
    ...
]
data_mem_start_address
label = {
    label1 : mem_address,
    ...
}

*/
function escape_space(string){
  if(typeof string !== 'string') {
    return string;
  }
  return string.replace(/ /g, "\u00a0")
}
function escape_html (string) {
  if(typeof string !== 'string') {
    return string;
  }
  return string.replace(/[&'`"<>]/g, function(match) {
    return {
      '&': '&amp;',
      "'": '&#x27;',
      '`': '&#x60;',
      '"': '&quot;',
      '<': '&lt;',
      '>': '&gt;',
    }[match]
  });
}
class Terminal extends Component {
  constructor(props) {
    super(props);
  
    this.state = {log: []};
    this.flush_log = this.flush_log.bind(this);
    log_flush = this.flush_log;
  }
  flush_log(){
    this.setState({log: log_buf});
    log_buf = [];
  }
  render(){
    return (
      <div id="terminal">
        {this.state.log.map((item, key) => 
          <span key={key}>{item}<br/></span>
        )}
      </div> 
    )
  }
}
var r = null
var r2 = null
class DataMem extends Component{
  constructor(props) {
    super(props);
  
    this.state = {mem: mem};
    this.refresh = this.refresh.bind(this);
    r = this.refresh
  }
  refresh(){
    this.setState({mem: mem});
  }
  render(){
    let list = [];
    for (let i = data_mem_start_address; i < hidden_start_address; i++) {
      list.push(<div key={i}>{mem[i]["label"].join(":") + ": " + mem[i]["data"]}</div>)
    }
    return (
      <div className="">
        {list}
      </div>
      )
  }
}
class InstructionMem extends Component{
  constructor(props) {
    super(props);
  
    this.state = {mem: mem};
    this.refresh = this.refresh.bind(this);
    r2 = this.refresh
  }
  refresh(){
    this.setState({mem: mem});
  }
  render(){
    let list = [];
    for (let i = 0; i < data_mem_start_address; i+=4) {
      list.push(<div className="row" key={i}>
        <div className="col-xs-3">{mem[i]["label"].join(":")+": "+ mem[i]["data"]}</div>
        <div className="col-xs-3">{mem[i+1]["label"].join(":")+": "+ mem[i+1]["data"]}</div>
        <div className="col-xs-3">{mem[i+2]["label"].join(":")+": "+ mem[i+2]["data"]}</div>
        <div className="col-xs-3">{mem[i+3]["label"].join(":")+": "+ mem[i+3]["data"]}</div>
      </div>)
    }
    return (
      <div className="">
        {list}
      </div>
      )
  }
}
class Memory extends Component{
  render(){
    return (
      <div>
        <DataMem />
        <InstructionMem />
      </div>
    )
  }
}

class App extends Component {
  componentDidMount() {
    editor = this.refs.editor.editor;
  }
  render() {
    return (
      <div className="App container-fluid">
        <div className="row">
          <div className="col-md-5">
            <AceEditor
              ref="editor"
              theme="github"
              name="editor"
              editorProps={{$blockScrolling: true}}
              width="100%"
            />
          </div>
          <div className="col-md-7">
            <Terminal />
            <button onClick={parse}>parse</button>
            <button onClick={execute}>execute</button>
            <button onClick={log_flush}>log_flush</button>
            <button onClick={test_print}>test_print</button>
            
            <Memory />
            
          </div>
        </div>
      </div>
    );
  }
}

export default App;
