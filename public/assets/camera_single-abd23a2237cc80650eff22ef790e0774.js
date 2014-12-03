(function(){var e,t,a,r,n,i,s,o,c,d,l,u,h,p;h=function(e){return Notification.show(e),!0},p=function(e){return Notification.show(e),!0},u=function(e){var t,a;return a=$('meta[name="csrf-token"]'),a.size()>0&&(t={"X-CSRF-Token":a.attr("content")},e.headers=t),jQuery.ajax(e),!0},e=function(e){var t,a,r,d,l,u,h,p;return l=$("<tr>"),"share_request"===e.type?l.attr("share-request-id",e.share_id):l.attr("share-id",e.share_id),a=$("<td>",{"class":"col-lg-4"}),a.append(document.createTextNode(" "+e.email)),"share_request"===e.type&&(p=$("<small>",{"class":"blue"}),p.text(" ...pending"),a.append(p)),l.append(a),a=$("<td>",{"class":"col-lg-2"}),r=$("<div>",{"class":"input-group"}),u=$("<select>",{"class":"form-control reveal","show-class":"show-save"}),u.focus(s),d=$("<option>",{value:"minimal"}),"full"!==e.permissions&&d.attr("selected","selected"),d.text("Read Only"),u.append(d),d=$("<option>",{value:"full"}),"full"===e.permissions&&d.attr("selected","selected"),d.text("Full Rights"),u.append(d),r.append(u),a.append(r),l.append(a),a=$("<td>",{"class":"col-lg-2"}),t=$("<button>",{"class":"save show-save btn btn-primary"}),t.text("Save"),t.click("share"===e.type?o:c),a.append(t),l.append(a),a=$("<td>",{"class":"col-lg-2"}),r=$("<div>",{"class":"form-group"}),h=$("<span>"),h.append($("<span>",{"class":"glyphicon glyphicon-remove"})),"share"===e.type?(h.addClass("delete-share-control"),h.append($(document.createTextNode("Remove"))),h.click(n),h.attr("share_id",e.share_id)):(h.addClass("delete-share-request-control"),h.append($(document.createTextNode("Revoke"))),h.click(i),h.attr("email",e.email)),h.attr("camera_id",e.camera_id),r.append(h),a.append(r),l.append(a),l.hide(),$("#sharing_list_table tbody").append(l),l.find(".save").hide(),l.fadeIn(),!0},d=function(e){var t,a,r,n,i,s,o;switch(e.preventDefault(),s=$("input[name=sharingOptionRadios]:checked").val(),t=$("#set_permissions_submit"),a=$("#sharing_tab_camera_id").val(),r={},s){case"public_discoverable":r["public"]=!0,r.discoverable=!0,$(".show-on-public").show(),$(".show-on-private").hide();break;case"public_undiscoverable":r["public"]=!0,r.discoverable=!1,$(".show-on-public").show(),$(".show-on-private").hide();break;default:r["public"]=!1,r.discoverable=!1,$(".show-on-public").hide(),$(".show-on-private").show()}return n=function(){return h("Update of camera permissions failed. Please contact support."),t.removeAttr("disabled"),!1},i=function(e){return e.success?p("Camera permissions successfully updated."):h("Update of camera permissions failed. Please contact support."),t.removeAttr("disabled"),!0},o={cache:!1,data:r,dataType:"json",error:n,success:i,type:"POST",url:"/share/camera/"+a},t.attr("disabled","disabled"),u(o),!0},n=function(e){var t,a,r,n,i,s;return e.preventDefault(),t=$(e.currentTarget),i=t.parent().parent().parent(),a={camera_id:t.attr("camera_id"),share_id:t.attr("share_id")},r=function(){return h("Delete of camera shared failed. Please contact support."),!1},n=function(e){var t;return e.success?(t=function(){return i.remove()},i.fadeOut(t)):h("Delete of camera shared failed. Please contact support."),!0},s={cache:!1,data:a,dataType:"json",error:r,success:n,type:"DELETE",url:"/share"},u(s),!0},i=function(e){var t,a,r,n,i,s;return e.preventDefault(),t=$(e.currentTarget),i=t.parent().parent().parent(),a={camera_id:t.attr("camera_id"),email:t.attr("email")},r=function(){return h("Delete of share request failed. Please contact support."),!1},n=function(e){var t;return e.success?(t=function(){return i.remove()},i.fadeOut(t)):h("Delete of share request failed. Please contact support."),!0},s={cache:!1,data:a,dataType:"json",error:r,success:n,type:"DELETE",url:"/share/request"},u(s),!0},r=function(a){var r,n,i,s;return a.preventDefault(),r=$("#sharingUserEmail").val(),s="Full Rights"!==$("#sharingPermissionLevel").val()?"minimal":"full",n=function(){return h("Failed to share camera."),!1},i=function(t){var a;if(t.success)"share"===t.type?(e(t),p("Camera successfully shared with user")):("share_request"===t.type,e(t),p("A notification email has been sent to the specified email address.")),$("#sharingUserEmail").val("");else{switch(a="Adding a camera share failed.",t.code){case"camera_not_found_error":a="Unable to locate details for the camera in the system. Please refresh your view and try again.";break;case"duplicate_share_error":a="The camera has already been shared with the specified user.";break;case"duplicate_share_request_error":a="A share request for that email address already exists for this camera.";break;case"share_grantor_not_found_error":a="Unable to locate details for the user granting the share in the system.";break;case"invalid_parameters":a="Invalid rights specified for share creation request.";break;default:a=t.message}h(a)}return!0},t($("#sharing_tab_camera_id").val(),r,s,i,n),!0},o=function(e){var t,a,r,n,i,s,o;return e.preventDefault(),t=$(this),s=t.parent().parent(),a=s.find("select"),r={permissions:a.val(),camera_id:$("#ec_cam_id").text().trim()},n=function(){return h("Update of share failed. Please contact support."),!1},i=function(e){return e.success?(p("Share successfully updated."),t.fadeOut()):h("Update of share failed. Please contact support."),!0},o={cache:!1,data:r,dataType:"json",error:n,success:i,type:"PATCH",url:"/share/"+s.attr("share-id")},u(o),!0},c=function(e){var t,a,r,n,i,s,o;return e.preventDefault(),t=$(this),s=t.parent().parent(),a=s.find("select"),r={permissions:a.val(),camera_id:$("#ec_cam_id").text().trim()},n=function(){return h("Update of share request failed. Please contact support."),!1},i=function(e){return e.success?(p("Share request successfully updated."),t.fadeOut()):h("Update of share request failed. Please contact support."),!0},o={cache:!1,data:r,dataType:"json",error:n,success:i,type:"PATCH",url:"/share/request/"+s.attr("share-request-id")},u(o),!0},t=function(e,t,a,r,n){var i,s;return i={camera_id:e,email:t,permissions:a},s={cache:!1,data:i,dataType:"json",error:n,success:r,type:"POST",url:"/share"},u(s),!0},s=function(){return $(this).parent().parent().parent().find("td:eq(2) button").fadeIn(),!0},l=function(){var e;return e=$(this).val(),$("div.desc").hide(),$("#Shares"+e).show(),!0},a=function(){return $("#set_permissions_submit").click(d),$(".delete-share-control").click(n),$(".delete-share-request-control").click(i),$("#submit_share_button").click(r),$(".update-share-button").click(o),$(".update-share-request-button").click(c),$(".save").hide(),$(".reveal").focus(s),$("input[name$='sharingOptionRadios']").click(l),Notification.init(".bb-alert"),!0},window.Evercam||(window.Evercam={}),window.Evercam.Share={initializeTab:a,createShare:t}}).call(this),function(){var e,t,a,r,n,i,s,o,c,d,l,u,h,p,f,v,m,_,g,w,b,k,y,T,C,D,M,x,S,E,P,j,R,F,I,N,O,q,U,Y,L,z,W,H,A,X,B,G,Q,Z,J,K,V,et,tt,at,rt,nt,it,st,ot,ct,dt,lt,ut;P="https://api.evercam.io/v1/",ct=null,dt=0,ot=0,N=0,j=0,w="tdI8",e=null,i=null,Q=!1,g=!1,tt=250,n=3600,K=1e3,lt=0,F="",Z=n,st=679,V=1,at=1,r=0,ut=null,et=null,rt=function(e){var t,a;return a=$('meta[name="csrf-token"]'),a.size()>0&&(t={"X-CSRF-Token":a.attr("content")},e.headers=t),ut=jQuery.ajax(e),!0},$(function(){$(".btn-group").tooltip()}),B=function(){return $("#ui_date_picker_inline").datepicker().on("changeDate",q).on("changeMonth",O),$("#ui_date_picker_inline table th[class*='prev']").on("click",function(){return R("p")}),$("#ui_date_picker_inline table th[class*='next']").on("click",function(){R("n")}),$("#hourCalandar td[class*='day']").on("click",function(){y($(this).html(),"tdI"+$(this).html())}),!0},R=function(e){var t,a,r,n,i,s,o,c;return ut.abort(),$("#ui_date_picker_inline").datepicker("fill"),n=$("#ui_date_picker_inline").datepicker("getDate"),s=n.getMonth(),"n"===e&&(s+=2),13===s&&(s=1),0===s&&(s=12),r=$("#recording_tab_camera_id").val(),t=$("#recording_tab_api_id").val(),a=$("#recording_tab_api_key").val(),i={},i.api_id=t,i.api_key=a,o=function(){return!1},c={cache:!1,data:i,dataType:"json",error:o,success:v,contentType:"application/json; charset=utf-8",type:"GET",url:""+P+"cameras/"+r+"/snapshots/"+n.getFullYear()+"/"+s+"/days.json"},rt(c),"n"===e?n.setMonth(n.getMonth()+1):"p"===e&&n.setMonth(n.getMonth()-1),$("#ui_date_picker_inline").datepicker("setDate",n),ct=null,ot=1,N=0,!0},q=function(a){var r,n,s,o,c;for(r=a.date,$("#divPointer").width(0),$("#divSlider").width(0),$("#ddlRecMinutes").val(0),$("#ddlRecSeconds").val(0),$("#divDisableButtons").removeClass("hide").addClass("show"),$("#divFrameMode").removeClass("show").addClass("hide"),$("#divPlayMode").removeClass("show").addClass("hide"),n=!1,o=0,c=e.length;c>o;o++)if(s=e[o],s===r.getDate()){n=!0;break}return I(),n?t(!1):m(),i=setTimeout(b,100),!0},O=function(e){var t,a,r,n,i,s,o;return n=e.date,r=$("#recording_tab_camera_id").val(),t=$("#recording_tab_api_id").val(),a=$("#recording_tab_api_key").val(),i={},i.api_id=t,i.api_key=a,s=function(){return!1},o={cache:!1,data:i,dataType:"json",error:s,success:v,contentType:"application/json; charset=utf-8",type:"GET",url:""+P+"cameras/"+r+"/snapshots/"+n.getFullYear()+"/"+(n.getMonth()+1)+"/days.json"},rt(o),ct=null,ot=1,N=0,!0},I=function(){var e;return $("#hourCalandar td[class*='day']").removeClass("active"),e=$("#hourCalandar td[class*='day']"),e.each(function(){var e;return e=$(this),e.removeClass("has-snapshot")}),!0},b=function(){var t;clearTimeout(i),null!=e&&(t=$("#ui_date_picker_inline table td[class*='day']"),t.each(function(){var t,a,r;if(t=$(this),!t.hasClass("old")&&!t.hasClass("new"))for(a=parseInt(t.text()),r=0;r<e.length;){if(e[r]===a){t.addClass("has-snapshot");break}r++}}))},H=function(){var e,t,a;return t=function(e){var t,a,r,n,i,s,o;if(null!==ct&&0!==ct.length)return s=$("#divSlider").offset().left,i=s+$("#divSlider").width(),n=(e.pageX-s)/(i-s),0>n&&(n=0),a=Math.round(n*dt),a>dt-1&&(a=dt-1),o=e.pageX-80,o>i-80&&(o=i-80),r="",t=a+1,$("#divPopup").html("Frame "+t+", "+(nt(new Date(1e3*ct[a].created_at))+r)),$("#divPopup").show(),$("#divPopup").offset({top:e.pageY+20,left:o}),$("#divSlider").css("background-position",""+(e.pageX-s)+"px 0px"),$("#divPointer").css("background-position",""+(e.pageX-s)+"px 0px"),!0},$("#divSlider").mousemove(t),a=function(){return $("#divPopup").hide(),$("#divSlider").css("background-position","-3px 0px"),$("#divPointer").css("background-position","-3px 0px"),!0},$("#divSlider").mouseout(a),e=function(e){var t,a,r,n,i;return n=$("#divSlider").offset().left,r=n+$("#divSlider").width(),i=e.pageX-n,a=i/(r-n),t=parseInt(dt*a),0>t&&(t=0),t>dt&&(t=dt),t!==dt&&t!==ot?(it(),ot=t,N=ot+1,E(ct[t]),!0):void 0},$("#divSlider").click(e),!0},it=function(){return-1!==$("#imgPlayback").attr("src").indexOf("nosnapshots")&&$("#imgPlayback").attr("src","/assets/plain.png"),$("#imgLoaderRec").width($("#imgPlayback").width()),$("#imgLoaderRec").height($("#imgPlayback").height()),$("#imgLoaderRec").css("top",$("#imgPlayback").css("top")),$("#imgLoaderRec").css("left",$("#imgPlayback").css("left")),$("#imgLoaderRec").show(),!0},T=function(e,t){var a;return $("#divInfo").fadeIn(),$("#divInfo").html("<b>Frame "+e+" of "+lt+"</b> "+t),a=$("#divSlider").width(),$("#divPointer").width(a*e/dt),$("#share-url").val(""+$("#tab-url").val()+"?date_time="+t.replace(RegExp("/","g"),"-").replace(" ","T")+"Z#recording"),!0},E=function(e){return it(),T(N,nt(new Date(1e3*e.created_at))),J(e.created_at),!0},Y=function(e){var t,a,r;return e=e.replace(/[\[]/,"\\[").replace(/[\]]/,"\\]"),a="[\\?&]"+e+"=([^&#]*)",t=new RegExp(a),r=t.exec(window.location.href),null==r?"":decodeURIComponent(r[1].replace(/\+/g," "))},L=function(){var e,a,n;return n=$("#camera_time_offset").val(),r=parseInt(n)/3600,e=U(n),j=e.getHours(),$("#hourCalandar td[class*='day']").removeClass("active"),a=Y("date_time"),""!==a&&(et=x(a.replace(RegExp("-","g"),"/").replace("T"," ").replace("Z","")),e=et,j=e.getHours(),$("#ui_date_picker_inline").datepicker("update",e)),$("#tdI"+j).addClass("active"),w="tdI"+j,$("#ui_date_picker_inline").datepicker("setDate",e),it(),f(),t(!1),!0},U=function(e){var t,a,r;return t=new Date,r=t.getTime()+6e4*t.getTimezoneOffset(),r+=parseInt(e),a=new Date(r)},f=function(){var e,t,a,r,n,i,s;return r=$("#ui_date_picker_inline").datepicker("getDate"),a=$("#recording_tab_camera_id").val(),e=$("#recording_tab_api_id").val(),t=$("#recording_tab_api_key").val(),n={},n.api_id=e,n.api_key=t,i=function(){return!1},s={cache:!1,data:n,dataType:"json",error:i,success:v,contentType:"application/json; charset=utf-8",type:"GET",url:""+P+"cameras/"+a+"/snapshots/"+r.getFullYear()+"/"+(r.getMonth()+1)+"/days.json"},rt(s),!0},v=function(t){var a;return a=$("#ui_date_picker_inline table td[class*='day']"),e=t.days,a.each(function(){var e,a,r,n,i,s,o;if(e=$(this),!e.hasClass("old")&&!e.hasClass("new")){for(a=parseInt(e.text()),s=t.days,o=[],n=0,i=s.length;i>n;n++){if(r=s[n],r===a){e.addClass("has-snapshot"),null!==et&&et.getDate()===a&&e.addClass("active");break}o.push(void 0)}return o}}),!0},t=function(e){var t,r,n,i,s,o,c;return $("#divDisableButtons").removeClass("hide").addClass("show"),$("#divFrameMode").removeClass("show").addClass("hide"),$("#divPlayMode").removeClass("show").addClass("hide"),i=$("#ui_date_picker_inline").datepicker("getDate"),n=$("#recording_tab_camera_id").val(),t=$("#recording_tab_api_id").val(),r=$("#recording_tab_api_key").val(),s={},s.api_id=t,s.api_key=r,o=function(){return!1},c={cache:!1,data:s,dataType:"json",error:o,success:a,context:{isCall:e},contentType:"application/json; charset=utf-8",type:"GET",url:""+P+"cameras/"+n+"/snapshots/"+i.getFullYear()+"/"+(i.getMonth()+1)+"/"+i.getDate()+"/hours.json"},rt(c),!0},a=function(e){var t,a,n,i,s,o,c;for(i=0,t=!1,c=e.hours,s=0,o=c.length;o>s;s++)a=c[s],n=a+r,$("#tdI"+n).addClass("has-snapshot"),i=n,t=!0;return t?this.isCall?d(!0):(null!==et&&(i=j),y(i,"tdI"+i)):m(),!0},d=function(e){var t,a,r,i,s,o,c,d,f;return $("#divDisableButtons").removeClass("hide").addClass("show"),$("#divFrameMode").removeClass("show").addClass("hide"),$("#divPlayMode").removeClass("show").addClass("hide"),e&&it(),s=l()/1e3,f=u()/1e3,r=$("#recording_tab_camera_id").val(),t=$("#recording_tab_api_id").val(),a=$("#recording_tab_api_key").val(),i={},i.from=s,i.to=f,i.limit=Z,i.page=1,i.api_id=t,i.api_key=a,o=function(){return!1},c=function(e){var t,a,r;return ot=0,ct=e.snapshots,dt=e.snapshots.length,lt=e.snapshots.length,null===e||0===e.snapshots.length?($("#divSliderMD").width("100%"),$("#MDSliderItem").html(""),$("#divNoMd").show(),m(),p()):($("#divDisableButtons").removeClass("show").addClass("hide"),$("#divFrameMode").removeClass("hide").addClass("show"),a=Math.ceil(lt/n),st=Math.ceil(100/a),st>100&&(st=100),$("#divSlider").width(""+st+"%"),N=1,t=new Date(1e3*ct[ot].created_at),r=ct[ot].created_at,null!==et&&(r=h(et)/1e3,r=C(r),t=new Date(1e3*r),1!==N&&(et=null)),T(N,nt(t)),J(r)),!0},d={cache:!1,data:i,dataType:"json",error:o,success:c,contentType:"application/json; charset=utf-8",type:"GET",url:""+P+"cameras/"+r+"/snapshots/range.json"},rt(d),!0},J=function(e){var t,a,r,n,i,s,o;return r=$("#recording_tab_camera_id").val(),t=$("#recording_tab_api_id").val(),a=$("#recording_tab_api_key").val(),n={},n.with_data=!0,n.range=1,n.api_id=t,n.api_key=a,i=function(){return!1},s=function(e){return e.snapshots.length>0&&$("#imgPlayback").attr("src",e.snapshots[0].data),p(),!0},o={cache:!1,data:n,dataType:"json",error:i,success:s,contentType:"application/json; charset=utf-8",type:"GET",url:""+P+"cameras/"+r+"/snapshots/"+e+".json"},rt(o),!0},C=function(e){var t;for(t=0;t<ct.length;){if(ct[t].created_at>=e)return N=t+1,ot=t,ct[t].created_at;t++}},h=function(e){var t;return t=Date.UTC(e.getFullYear(),e.getMonth(),e.getDate(),e.getHours(),e.getMinutes(),e.getSeconds())},x=function(e){var t,a,r,n;return r=e.substring(e.indexOf(" ")),t=e.substring(0,e.indexOf(" ")),n=r.split(":"),a=t.split("/"),new Date(a[2],a[1]-1,a[0],n[0],n[1],n[2])},nt=function(e){var t,a;return t=$("#ui_date_picker_inline").datepicker("getDate"),a=parseInt(j),""+c(t.getDate())+"/"+c(t.getMonth()+1)+"/"+e.getFullYear()+" "+c(a)+":"+c(e.getMinutes())+":"+c(e.getSeconds())},l=function(){var e,t,a;return e=$("#ui_date_picker_inline").datepicker("getDate"),a=parseInt(j),t=Date.UTC(e.getFullYear(),e.getMonth(),e.getDate(),a,0,0)},u=function(){var e,t,a;return e=$("#ui_date_picker_inline").datepicker("getDate"),t=parseInt(j)+1,a=0,a=24===t?Date.UTC(e.getFullYear(),e.getMonth(),e.getDate(),23,59,59):Date.UTC(e.getFullYear(),e.getMonth(),e.getDate(),t,0,0)},S=function(e){return e.length>1&&"0"===e.substr(0,1)?e.substr(1):e},s=function(e){var t,a,r,n,i,s,o;return null===e?"":(o=e.getFullYear(),i=e.getMonth()+1,t=e.getDate(),a=e.getHours(),n=e.getMinutes(),s=e.getSeconds(),r=""+e.getMilliseconds(),2===r.length?r="0"+r:1===r.length?r="00"+r:(0===r.length||0===r)&&(r=""),""+(c(o)+c(i)+c(t)+c(a)+c(n)+c(s)+r))},c=function(e){return 10>e?"0"+e:e},m=function(){return $("#divRecent").show(),$("#imgPlayback").attr("src","/assets/nosnapshots.svg"),$("#divInfo").fadeOut(),$("#divPointer").width(0),$("#divSliderBackground").width(0),$("#MDSliderItem").html(""),$("#divNoMd").show(),$("#divNoMd").text("No motion detected"),p(),dt=0,!0},y=function(e,t){var a;return a=$("#"+t).html(),$("#ddlRecMinutes").val(0),$("#ddlRecSeconds").val(0),j=e,$("#"+w).removeClass("active"),$("#"+t).addClass("active"),w=t,ct=null,_(),N=0,$("#divPointer").width(0),$("#divSlider").width("0%"),$("#divDisableButtons").removeClass("hide").addClass("show"),$("#divFrameMode").removeClass("show").addClass("hide"),$("#divPlayMode").removeClass("show").addClass("hide"),$("#"+t).hasClass("has-snapshot")?($("#divSliderBackground").width("100%"),$("#divSliderMD").width("100%"),$("#MDSliderItem").html(""),$("#divNoMd").show(),$("#btnCreateHourMovie").removeAttr("disabled"),d(!0)):($("#divRecent").show(),$("#divInfo").fadeOut(),$("#divSliderBackground").width("0%"),$("#txtCurrentUrl").val(""),$("#divSliderMD").width("100%"),$("#MDSliderItem").html(""),$("#btnCreateHourMovie").attr("disabled",!0),dt=0,$("#imgPlayback").attr("src","/assets/nosnapshots.svg"),$("#divNoMd").show(),$("#divNoMd").text("No motion detected"),p()),!0},_=function(){return Q=!1,$("#divFrameMode").removeClass("hide").addClass("show"),$("#divPlayMode").removeClass("show").addClass("hide"),g=!0},p=function(){return $("#imgLoaderRec").hide()},X=function(){return $(window).on("resize",function(){var e;return e=$("#divSlider").width(),$("#divPointer").width(e*N/dt)})},W=function(){return $("#btnPlayRec").on("click",function(){return 0!==dt?(V=1,at=1,$("#divFrameMode").removeClass("show").addClass("hide"),$("#divPlayMode").removeClass("hide").addClass("show"),Q=!0,ct.length===ot+1&&(ot=0,N=1),o()):void 0}),$("#btnPauseRec").on("click",function(){return _()}),$("#btnFRwd").on("click",function(){return D(10,-1)}),$("#btnRwd").on("click",function(){return D(5,-1)}),$("#btnFFwd").on("click",function(){return D(10,1)}),$("#btnFwd").on("click",function(){return D(5,1)}),$(".skipframe").on("click",function(){switch($(this).html()){case"+ Frame":return M(1,"n");case"+5":return M(5,"n");case"+10":return M(10,"n");case"+100":return M(100,"n");case"- Frame":return M(1,"p");case"-5":return M(5,"p");case"-10":return M(10,"p");case"-100":return M(100,"p")}})},M=function(e,t){if("p"===t){if(0===ot)return;0>ot-e?(N=1,ot=0):(N-=e,ot-=e)}else if("n"===t){if(ct.length===ot+1)return;ot+e>ct.length-1?(ot=ct.length-1,N=ct.length):(N+=e,ot+=e)}g=!1,V=1,E(ct[ot])},D=function(e,t){V=t,at=e},o=function(){var e,t,a,r,n,i,s,c;if(0!==dt){if(ct.length===ot)return _(),N=ct.length,void(ot=ct.length-1);c=ct[ot],a=$("#recording_tab_camera_id").val(),e=$("#recording_tab_api_id").val(),t=$("#recording_tab_api_key").val(),r={},r.with_data=!0,r.range=1,r.api_id=e,r.api_key=t,n=function(){return 1===V&&1===at?(N++,ot++):1===V&&at>1?(N+=at,N>=ct.length&&(N=ct.length),ot+=at,ot>ct.length-1&&(ot=ct.length-1)):-1===V&&at>1&&(N-=at,1>=N&&(N=1),ot-=at,0>ot&&(ot=0),0===ot&&_()),Q&&window.setTimeout(o,tt),!1},i=function(e){return e.snapshots.length>0&&T(N,nt(new Date(1e3*c.created_at))),$("#imgPlayback").attr("src",e.snapshots[0].data),1===V&&1===at?(N++,ot++):1===V&&at>1?(N+=at,N>=ct.length&&(N=ct.length),ot+=at,ot>ct.length-1&&(ot=ct.length-1)):-1===V&&at>1&&(N-=at,1>=N&&(N=1),ot-=at,0>ot&&(ot=0),0===ot&&_()),Q&&window.setTimeout(o,tt),!0},s={cache:!1,data:r,dataType:"json",error:n,success:i,contentType:"application/json; charset=utf-8",type:"GET",url:""+P+"cameras/"+a+"/snapshots/"+c.created_at+".json"},rt(s)}},k=function(){var e,t,a,r,n,i;if(a=c($("#ddlRecMinutes").val()),n=c($("#ddlRecSeconds").val()),e=Math.round(ct.length/60*parseInt(a)),e<ct.length-1)for(t=0;t<ct.length;){if(i=ct[t],r=i.date.substring(i.date.indexOf(" ")+1).split(":"),r[1]===a){if(r[2]===n)return N=t+1,ot=t,void E(i);if(r[2]>n)return N=t,ot=t-1,i=ct[ot],r=i.date.substring(i.date.indexOf(" ")+1).split(":"),$("#ddlRecSeconds").val(r[2]),void E(i)}else if(r[1]>a)return N=t,ot=t-1,i=ct[ot],r=i.date.substring(i.date.indexOf(" ")+1).split(":"),$("#ddlRecSeconds").val(r[2]),void E(i);t++}else N=ct.length+1,ot=ct.length,E(ct[ot])},z=function(){var e,t;for(e=1;59>=e;)t=$("<option>").val(c(e)).append(c(e)),$("#ddlRecMinutes").append(t),t=$("<option>").val(c(e)).append(c(e)),$("#ddlRecSeconds").append(t),e++;$("#ddlRecMinutes").on("change",function(){k()}),$("#ddlRecSeconds").on("change",function(){k()})},A=function(){return $('a[data-toggle="tab"]').on("click",function(){var e;return e=$(this).html(),"Snapshots"===e&&null===et?d(!1):void 0}),$("#share-url").on("click",function(){return this.select()})},G=function(){return B(),X(),L(),z(),W(),A(),!0},window.Evercam||(window.Evercam={}),window.Evercam.Recordings={initializeTab:G}}.call(this),function(){var e,t;t=function(){return!0},e=function(){return $("#set_permissions_submit").click(t),$("img.snap").each(function(){var e;return e=$(this),$("<img />").attr("src",$(this).attr("data-proxy")).load(function(){return this.complete&&void 0!==this.naturalWidth&&0!==this.naturalWidth?e.replaceWith($(this)):console.log("camera offline")})}),$("#live-refresh").click(function(){var e;return e=$(".camera-preview img"),$("<img />").attr("src",e.attr("src")).load(function(){return e.replaceWith($(this))}),!1}),!0},window.Evercam||(window.Evercam={}),window.Evercam.Live={initializeTab:e}}.call(this),function(){var e,t,a,r,n,i,s;r=function(){return!0},s=function(){return $(".nav-tabs a[href=#sharing]").tab("show"),setTimeout(function(){return scrollTo(0,0)},10)},t=function(e){return e.preventDefault(),i(!0),!0},n=function(e){return $("#change_owner_error").text(e),""===e?$("#change_owner_error").hide():$("#change_owner_error").show(),!0},a=function(e){var t,a,r,s,o,c;return e.preventDefault(),r=$("#new_owner_email"),""!==r.val()&&(a=$("#change_owner_dialog"),a.modal("hide"),n(""),s=function(){return n("An error occurred transferring ownership of this camera. Please try again and, if the problem persists, contact support."),i(!1),!0},o=function(e){var t;return e.success?(alert("Camera ownership has been successfully transferred."),t=window.location,t.assign(t.protocol+"//"+t.host)):(n(e.message),i(!1)),!0},t={camera_id:$("#change_owner_camera_id").val(),email:r.val()},c={cache:!1,data:t,error:s,success:o,url:"/cameras/transfer"},jQuery.ajax(c)),!0},i=function(e){var t;return e&&($("#new_owner_email").val(""),$("#change_owner_error").hide()),$("#change_owner_dialog").modal("show"),t=function(){return $("#new_owner_email").select()},setTimeout(t,200),!0},e=function(){return $("#set_permissions_submit").click(r),$(".open-sharing").click(s),$("#change_owner_button").click(t),$("#submit_change_owner_button").click(a),!0},window.Evercam||(window.Evercam={}),window.Evercam.Info={initializeTab:e}}.call(this),function(){var e,t;t=function(){return!0},e=function(){return $("#set_permissions_submit").click(t),!0},window.Evercam||(window.Evercam={}),window.Evercam.Settings={initializeTab:e}}.call(this),function(){var e,t;t=function(){return!0},e=function(){return $("#set_permissions_submit").click(t),!0},window.Evercam||(window.Evercam={}),window.Evercam.Explorer={initializeTab:e}}.call(this),function(){var e,t,a,r;t=null,r=function(){var e,a,r,n,i,s,o;return e=$("#exid").val(),i=$("#current-page").val(),o=[],$.each($("input[name='type']:checked"),function(){return o.push($(this).val())}),a=new Date($("#datetimepicker").val()).getTime()/1e3,s=new Date($("#datetimepicker2").val()).getTime()/1e3,r="",isNaN(a)||(r+="&from="+a),isNaN(s)||(r+="&to="+s),n=$("#base-url").val()+"&page="+i+"&types="+o.join()+r,null!=t&&t.ajax.url(n).load(),null==t&&$("#ajax-url").val(n),!0},a=function(){return $("#all-types").is(":checked")?$("input[name='type']").prop("checked",!0):$("input[name='type']").prop("checked",!1)},e=function(){return $("#apply-types").click(r),$(".datetimepicker").datetimepicker(),$("#all-types").click(a),jQuery.fn.DataTable.ext.type.order["string-date-pre"]=function(e){return moment(e,"MMMM Do YYYY, H:mm:ss").format("X")},r(),t=$("#logs-table").DataTable({ajax:{url:$("#ajax-url").val(),dataSrc:"logs",error:function(e){return Notification.show(e.responseJSON.message)}},columns:[{data:function(e){return moment(1e3*e.done_at).format("MMMM Do YYYY, H:mm:ss")},orderDataType:"string-date",type:"string-date"},{data:function(e){return"shared"===e.action||"stopped sharing"===e.action?e.action+" with "+e.extra["with"]:e.action},className:"log-action"},{data:function(e){return"online"===e.action||"offline"===e.action?"System":e.who}}],iDisplayLength:50,order:[[0,"desc"]]}),!0},window.Evercam||(window.Evercam={}),window.Evercam.Logs={initializeTab:e}}.call(this),function(){var e,t,a,r,n,i,s,o,c;o=function(e){return Notification.show(e),!0},c=function(e){return Notification.show(e),!0},s=function(e){var t,a;return a=$('meta[name="csrf-token"]'),a.size()>0&&(t={"X-CSRF-Token":a.attr("content")},e.headers=t),jQuery.ajax(e),!0},e=function(e){var t,a,r,i,s;return i=$("<tr>"),i.attr("webhook-id",e.id),r=document.createElement("a"),r.appendChild(document.createTextNode(e.url)),r.href=e.url,r.target="_blank",t=$("<td>",{"class":"col-lg-8"}),t.append(r),i.append(t),t=$("<td>",{"class":"col-lg-2"}),a=$("<div>",{"class":"form-group"}),s=$("<span>"),s.append($("<span>",{"class":"glyphicon glyphicon-remove"})),s.addClass("delete-webhook-control"),s.append($(document.createTextNode(" Remove"))),s.click(n),s.attr("webhook_id",e.webhook_id),s.attr("camera_id",e.camera_id),a.append(s),t.append(a),i.append(t),i.hide(),$("#webhook_list_table tbody").append(i),i.fadeIn(),!0},n=function(e){var t,a,r,n,i,c;return e.preventDefault(),t=$(e.currentTarget),i=t.parent().parent().parent(),a={camera_id:t.attr("camera_id"),webhook_id:t.attr("webhook_id")},r=function(){return o("Deleting webhook failed. Please contact support."),!1},n=function(){var e;return t.off(),e=function(){return i.remove()},i.fadeOut("slow",e),!0},c={cache:!1,data:a,dataType:"json",error:r,success:n,type:"DELETE",url:"/webhooks/"+i.attr("webhook-id")},s(c),!0},r=function(a){var r,n,i;return a.preventDefault(),i=$("#newWebhookUrl").val(),""===i?void o("Webhook URL can't be blank."):(r=function(){return o("Failed to add new webhook to the camera."),!1},n=function(t){return t.success?(e(t),c("Webhook successfully added to the camera"),$("#newWebhookUrl").val("")):o("Failed to add new webhook to the camera. The provided url is not valid."),!0},t($("#sharing_tab_camera_id").val(),i,n,r),!0)},t=function(e,t,a,r){var n,i;return n={camera_id:e,url:t,user_id:window.Evercam.current_user},i={cache:!1,data:n,dataType:"json",error:r,success:a,type:"POST",url:"/webhooks"},s(i),!0},i=function(){return $(this).parent().parent().parent().find("td:eq(2) button").fadeIn(),!0},a=function(){return $(".delete-webhook-control").click(n),$("#submit_webhook_button").click(r),$("#newWebhookUrl").keypress(function(e){return 13===e.which?$("#submit_webhook_button").trigger("click"):void 0}),$(".save").hide(),$(".reveal").focus(i),Notification.init(".bb-alert"),!0},window.Evercam||(window.Evercam={}),window.Evercam.Webhook={initializeTab:a,createWebhook:t}}.call(this);