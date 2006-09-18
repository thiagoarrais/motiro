function showOnly(divId) {
    document.getElementById('changes').style.display = 'block';

    var diffs = getElementsBySelector("div.diff-window")
    
    for(i=0; i < diffs.length; i++) {
        diffs[i].style.display = 'none'
    }
    
    var div = document.getElementById(divId);
    if(div) {
        div.style.display = 'block';
    }
}

function tooglePasswordConfirmation(show) {
	var cells = getElementsBySelector("td.password_confirm");
	var state = show ? 'block' : 'none';
	var action = show ? '/account/signup' : '/account/login' ;
            
	document.getElementById("user_password_confirmation").disabled = !show;
	document.forms[0].action = action;

	for(i=0; i < cells.length; i++) {
		cells[i].style.display = state;
	}
}

function check_password_confirmation() {
    var passwd = document.getElementById('user_password').value;
    var passwd_confirm = document.getElementById('user_password_confirmation').value;
    var do_not_match_warn = document.getElementById('passwords_do_not_match');
    
    if (passwd_confirm == '' || passwd == '' || passwd == passwd_confirm) {
      do_not_match_warn.style.display = 'none';
    } else {
      do_not_match_warn.style.display = 'block';
    }
}

//copied from niftycube
//TODO try to DRY this
function getElementsBySelector(selector){
var i,j,selid="",selclass="",tag=selector,tag2="",v2,k,f,a,s=[],objlist=[],c;
if(selector.find("#")){ //id selector like "tag#id"
    if(selector.find(" ")){  //descendant selector like "tag#id tag"
        s=selector.split(" ");
        var fs=s[0].split("#");
        if(fs.length==1) return(objlist);
        f=document.getElementById(fs[1]);
        if(f){
            v=f.getElementsByTagName(s[1]);
            for(i=0;i<v.length;i++) objlist.push(v[i]);
            }
        return(objlist);
        }
    else{
        s=selector.split("#");
        tag=s[0];
        selid=s[1];
        if(selid!=""){
            f=document.getElementById(selid);
            if(f) objlist.push(f);
            return(objlist);
            }
        }
    }
if(selector.find(".")){      //class selector like "tag.class"
    s=selector.split(".");
    tag=s[0];
    selclass=s[1];
    if(selclass.find(" ")){   //descendant selector like tag1.classname tag2
        s=selclass.split(" ");
        selclass=s[0];
        tag2=s[1];
        }
    }
var v=document.getElementsByTagName(tag);  // tag selector like "tag"
if(selclass==""){
    for(i=0;i<v.length;i++) objlist.push(v[i]);
    return(objlist);
    }
for(i=0;i<v.length;i++){
    c=v[i].className.split(" ");
    for(j=0;j<c.length;j++){
        if(c[j]==selclass){
            if(tag2=="") objlist.push(v[i]);
            else{
                v2=v[i].getElementsByTagName(tag2);
                for(k=0;k<v2.length;k++) objlist.push(v2[k]);
                }
            }
        }
    }
return(objlist);
}
