<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<script>

    // 설정한 필드 값 보이기
	$(function(){
		var checkBox = $('.fieldCheck');
		$('.fieldItem').each(function(index){
    		$(this).text("");
    	});
		
		$('.field-content').each(function(i){
			$(this).css({
				"visibility" : "hidden"
			})
		})
		$.ajax({
			url : "<%=request.getContextPath()%>/approval/getFieldSetting.do",
			type : 'get',
			success : function(res){
				$.each(res, function(i,v){
			    	checkBox.each(function(index){
			    		var field = $(this).val();
			    		if($(this).val() == v.field){
			    			$(this).attr("checked", true);
			    			$('#' + field).text(v.field);
			    			$('[data-field=' + field + ']').css({
			    				"visibility" : "visible"
			    			});
			    		}
			    	});
				})
			},
			error : function(error){
				AjaxErrorSecurityRedirectHandler(error.status);
			}
		})	
	});
	
    // 필드값 저장
    function fieldSave(){
    	var fieldList = []
    	var checkBox = $('.fieldCheck');
    	checkBox.each(function(index){
    		var field = $(this).val();
    		if($(this).is(":checked")){    			
	    		fieldList.push(field);
    		}
    	});
    	
    	$.ajax({
    		url : '<%=request.getContextPath()%>/approval/fieldSetting.do',
    		type : 'post',
    		data : JSON.stringify(fieldList),
    		contentType:'application/json',
    		success : function(res){
    			Swal.fire({
				      icon: 'success',
				      title: '필드가 저장되었습니다.',
				      confirmButtonColor: '#3085d6',
				    }).then(function(){
				      });
		    			location.reload();
    		},
    		error : function(error){
    			AjaxErrorSecurityRedirectHandler(error.status);
    		}
    	});
    }

</script>

<script>
//페이지네이션
function list_go(url, page, signState){
		var signs = 0;
		signs = signState;
		var jobForm=$('#jobForm');
		jobForm.find("[name='page']").val(page);
		jobForm.find("[name='perPageNum']").val();
		jobForm.find("[name='searchType']").val($('select[name="searchType"]').val());
		jobForm.find("[name='keyword']").val($('input[name="keyword"]').val());
		jobForm.find("[name='signState']").val(signs);
		jobForm.find("[name='signForm']").val($('select[name="signForm"]').val());
		jobForm.find("[name='mCode']").val();

		jobForm.attr({
			action:url,
			method:'get'
		}).submit();
	}
</script>

<script>

// 결재문서함 결재 버튼
function approveSignDoc(){
	var signLineno = $('input[name="signLineno"]').val(); // 결재선 번호
	var signNo = $('input[name="signNo"]').val(); // 문서번호
	var signRank = $('input[name="${loginUser.eno}"]').val(); // 결재 순서
	
	var first = $('input[name="${loginUser.eno}First"]').val(); // 처음 결재자
	if(typeof first == 'undefined'){ // 처음 결재자가 아닐 경우
		first = "no";
	}
	
	var last = $('input[name="${loginUser.eno}Last"]').val(); // 최종 결재자
	if(typeof last == 'undefined'){ // 최종 결재자가 아닐 경우
		last = "no";
	}
	
	var signComment = $("#signComment").val(); // 결재 코멘트
	var data = {
			'signLineno' : signLineno,
			'signRank' : signRank,
			'last' : last,
			'first' : first,
			'signNo' : signNo,
			'signComment' : signComment
	}
	
	// 다음 결재자
	signerEno = $('input[name="${loginUser.eno}"]').closest('#signAdd').next().find('input[name="signerEno"]').val();
	
	if(typeof signerEno == 'undefined'){ // 최종 결재자인 경우 기안자에게 알림 전송
		parent.sendSignal(${signDoc.eno},"${signDoc.title}","C102","approval/draftList.do","M124000");
	} else { // 다음 결재자에게 알림 전송
		parent.sendSignal(signerEno,"${signDoc.title}","C102","approval/approveList.do","M122000");
	}
	
	$.ajax({
		url : '<%=request.getContextPath()%>/approval/approveSignDoc.do',
		data : data,
		type : 'post',
		success: function(res){
			Swal.fire({
			      icon: 'success',
			      title: res,
			      confirmButtonColor: '#3085d6',
			    }).then(function(){
					window.location.reload();
			      });
		},
		error:function(error){
			AjaxErrorSecurityRedirectHandler(error.status);
		}
	});
}


// 결재문서함 반려 버튼
function rejectSignDoc(){
	var signLineno = $('input[name="signLineno"]').val();
	console.log(signLineno);
	var signRank = $('input[name="${loginUser.eno}"]').val();
	console.log(signRank);
	var signNo = $('input[name="signNo"]').val();
	
	var rejectComment = $("#rejectComment").val();
	console.log("rejectComment", rejectComment);
	
	
	var data = {
			'signLineno' : signLineno,
			'signRank' : signRank,
			'signComment' : rejectComment,
			'signNo' : signNo
	}
	
	parent.sendSignal(${signDoc.eno},"${signDoc.title}","C103","approval/draftList.do","M124000");
	
	$.ajax({
		url : '<%=request.getContextPath()%>/approval/rejectSignDoc.do',
		data : data,
		type : 'post',
		success: function(res){
			Swal.fire({
			      icon: 'success',
			      title: res,
			      confirmButtonColor: '#3085d6',
			    }).then(function(){
					window.location.reload();
			      });
		},
		error:function(error){
			AjaxErrorSecurityRedirectHandler(error.status);
		}
	});
}


// 결재문서함 보류 버튼
function waitSignDoc(){
	var signLineno = $('input[name="signLineno"]').val();
	console.log(signLineno);
	var signRank = $('input[name="${loginUser.eno}"]').val();
	console.log(signRank);
	
	var waitComment = $("#waitComment").val();
	console.log("waitComment", waitComment);
	
	
	var data = {
			'signLineno' : signLineno,
			'signRank' : signRank,
			'signComment' : waitComment
	}
	
	$.ajax({
		url : '<%=request.getContextPath()%>/approval/waitSignDoc.do',
		data : data,
		type : 'post',
		success: function(res){
			Swal.fire({
			      icon: 'success',
			      title: res,
			      confirmButtonColor: '#3085d6',
			    }).then(function(){
					window.location.reload();
			      });
		},
		error:function(error){
			AjaxErrorSecurityRedirectHandler(error.status);
		}
	});
}

// 기안문서함 삭제 버튼
function deleteSdoc(){
	var form = $('form[name="deleteSignDoc"]');
	$('form[name="deleteSignDoc"]').attr("action", "deleteSignDoc.do");
	console.log(form);
	form.submit();
}

// 임시문서함 삭제 버튼
function deleteTempSdoc(){
	var form = $('form[name="deleteSignDoc"]');
	$('form[name="deleteSignDoc"]').attr("action", "deleteTempSignDoc.do");
	console.log(form);
	form.submit();
}




</script>