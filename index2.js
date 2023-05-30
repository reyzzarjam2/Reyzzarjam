function onCreate() {
  iShowToast();
}
// TOAST ----------
function iShowToast() {
  var x = document.getElementById("iToast");
  x.className = "show";
  setTimeout(function() {
    x.className = x.className.replace("show", "");
  }, 1000 + 1000 + 1000);
}
// SPINNER ----------
let spin = document.querySelector('.iLoaderCover');
window.addEventListener('load', () => {
  spin.classList.add('iHideLoader');
  setTimeout(() => {
    spin.remove();
  }, 10 * 10 * 10 + 1000);
});
// FPS ----------
var fps = document.getElementById("iFps");
var startTime = Date.now();
var frame = 0;
function iFpsMeter() {
  var time = Date.now();
  frame++;
  if (time - startTime > 1000) {
    fps.innerHTML = (frame / ((time - startTime) / 1000)).toFixed(1);
    startTime = time;
    frame = 0;
  }
}
window.requestAnimationFrame(iFpsMeter);
iFpsMeter();
// COUNTER ----------
var counterContainer = document.querySelector(".website-counter");
var resetButton = document.querySelector("#reset");
var visitCount = localStorage.getItem("page_view");
if (visitCount) {
  visitCount = Number(visitCount) + 1;
  localStorage.setItem("page_view", visitCount);
} else {
  visitCount = 1;
  localStorage.setItem("page_view", 1);
}
counterContainer.innerHTML = visitCount;
resetButton.addEventListener("click", () => {
  visitCount = 1;
  localStorage.setItem("page_view", 1);
  counterContainer.innerHTML = visitCount;
});
// SOCIAL ----------
function iYoutube() {
  setTimeout(function() {
    window.open('https://youtube.com/@reyzzarjam', '_blank')},
    100);
}
function iInstagram() {
  setTimeout(function() {
    window.open('https://www.instagram.com/reyzzarjam/', '_blank')},
    100);
}
function iDiscord() {
  setTimeout(function() {
    window.open('https://discord.gg/dHPxjYfusG', '_blank')},
    100);
}
function iTelegram() {
  setTimeout(function() {
    window.open('https://t.me/CyberSecurity_ID', '_blank')},
    100);
}
// N A V ----------
function iHome() {
  setTimeout(function() {
    window.open('/', '_blank')},
    100);
}
function iTmc() {
  setTimeout(function() {
    window.open('../project', '_blank')},
    100);
}
function iNbt() {
  setTimeout(function() {
    window.open('./notify')},
    100);
}
function iFtr() {
  setTimeout(function() {
    window.open('./fitur', '_blank')},
    100);
}
// DOWNLOAD ----------
function q() {
  setTimeout(function() {
    window.open('https://short2fly.xyz/mzkQc', '_blank')},
    100);
}
function p() {
  setTimeout(function() {
    window.open('https://short2fly.xyz/x3FE', '_blank')},
    100);
}
function o() {
  setTimeout(function() {
    window.open('https://short2fly.xyz/WZTy6Oz', '_blank')},
    100);
}
function n() {
  setTimeout(function() {
    window.open('https://short2fly.xyz/dL6eFK', '_blank')},
    100);
}
function m() {
  setTimeout(function() {
    window.open('https://short2fly.xyz/Uk85', '_blank')},
    100);
}
function l() {
  setTimeout(function() {
    window.open('https://short2fly.xyz/vd9lEn', '_blank')},
    100);
}
function k() {
  setTimeout(function() {
    window.open('https://short2fly.xyz/wTENT2QG', '_blank')},
    100);
}
function j() {
  setTimeout(function() {
    window.open('https://short2fly.xyz/2yRsY8', '_blank')},
    100);
}
function i() {
  setTimeout(function() {
    window.open('https://short2fly.xyz/xq9ny', '_blank')},
    100);
}
function h() {
  setTimeout(function() {
    window.open('https://short2fly.xyz/BPIONm', '_blank')},
    100);
}
function g() {
  setTimeout(function() {
    window.open('https://short2fly.xyz/DiCeEuZ', '_blank')},
    100);
}
function f() {
  setTimeout(function() {
    window.open('https://short2fly.xyz/1WCfr', '_blank')},
    100);
}
function e() {
  setTimeout(function() {
    window.open('https://short2fly.xyz/l4y5SwSX', '_blank')},
    100);
}
function d() {
  setTimeout(function() {
    window.open('https://short2fly.xyz/Am2eY', '_blank')},
    100);
}
function c() {
  setTimeout(function() {
    window.open('https://short2fly.xyz/siXhme', '_blank')},
    100);
}
function b() {
  setTimeout(function() {
    window.open('https://short2fly.xyz/ReT24V9V', '_blank')},
    100);
}
function a() {
  setTimeout(function() {
    window.open('https://short2fly.xyz/WLVdlH', '_blank')},
    100);
}
//------------------------------------//