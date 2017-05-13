$(document).ready(function() {
    $("#load-captcha").click(function() {
        $("#load-captcha")
            .html('<span class="glyphicon glyphicon-refresh glyphicon-refresh-animate"></span> Loading...');
        $.ajax({
            url: "audio",
            type: "GET",
            success: function(result) {
                $("#audio-captcha").attr('src', result);
                $("#load-captcha").html('Load new captcha');
            }
        });
    });
    $("#audio-play").click(function() {
        $("#audio-captcha").trigger('play');
    });
    $("#verify-captcha").click(function() {
        if ($("#input-captcha").val() === "") {
            alert("You have to input the verification code! Are you really human?");
        } else {
            var code = $("#input-captcha").val();
            var verifyUrl = "audio_check/" + code;
            $.ajax(verifyUrl,
            {
                statusCode: {
                    200: function(response) {
                        alert("Captcha correct!");
                    },
                    409: function(response) {
                        alert("Captcha incorrect!");
                    }
                }
            });
        }
    });
    $("#load-video").click(function() {
        $("#load-video").html('<span class="glyphicon glyphicon-refresh glyphicon-refresh-animate"></span> Loading...');
        $("#tip").hide();
        $.ajax({
            url: "video",
            type: "GET",
            success: function(result) {
                var hehe = videojs('video-captcha');
                hehe.src(result.video);
                $("#video-question").attr('src', result.audio);
                $("#load-video").html('Load new captcha');
                hehe.on('play', function () {
                    $("#video-question").trigger('play');
                });
            }
        });
    });
    $("#verify-video-captcha").click(function() {
        if ($("#input-video-captcha").val() === "") {
            alert("You have to input the verification code! Are you really human?");
        } else {
            var code = $("#input-video-captcha").val();
            var verifyUrl = "video_check/" + code;
            $.ajax(verifyUrl,
            {
                statusCode: {
                    200: function(response) {
                        alert("Captcha correct!");
                    },
                    409: function(response) {
                        alert("Captcha incorrect!");
                    }
                }
            });
        }
    });
    
});