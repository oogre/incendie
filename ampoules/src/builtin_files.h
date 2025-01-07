static const char confPage[] PROGMEM =
R"==(
<!doctype html>
<html lang='en'>

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>🔥Configuration</title>
  <style>
    html, body{
      overflow: hidden;
      height: 100%;
      background: rgb(35, 25, 25);
      color: rgb(225, 235, 235);
    }
    body{
        display: flex;
        text-align: center;
        justify-content: center;
        align-items: center;
        flex-direction: column;
    }    
    form{
      display: flex;
      flex-direction: column;
    }
    label{
      position: relative;
    }
    label>span{
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    input{
      padding: 5px;
      margin: 5px 8px;
    }

    input[type="submit"]{
      margin: 5px 8px 5px 0;
      background: burlywood;
      border: solid 1px black;
    }
    .info{
      font-size: medium;
      background: lightgray; 
      padding: 10px;
      display: block;
      position: absolute;
      top: 0;
      transform: translate(0, -50%);
      z-index: 10;
      border-radius: 5px;
      color: black;
      border: solid 1px darkgoldenrod;
    }
    .hide{
      display: none !important;
    }
    .fireplace{
      font-size: 10em;
    } 
    .mirror{
      transform: scaleX(-1);
    } 
  </style>
</head>
<body>
  <div class="fireplace">
    <div>🔥</div>
  </div>
  <h3>incendie</h3>
  <h1>Configure ton WiFi</h1>
  <div>
    <form type>
      <label>
        <span>
          <span>SSID : </span>
          <input type="text" name="ssid"/>
        </span>
        <span class="info hide">C'est le nom de ton réseau wifi ( 2.4GHz )</span>
      </label>
      <label>
        <span>
          <span>Password : </span>
          <input type="password"  name="pwd"/>
        </span>
        <span class="info hide">C'est le mot de passe de ton réseau WPA/WPA2</span>
      </label>
      <input type="submit" value="Valider"/>
    </form>
  </div>
  <script>
    let infoTimer;
    [...document.querySelectorAll(".info")].map(e=>{
      e.parentElement.addEventListener("mouseenter", ()=>{
        infoTimer = setTimeout(()=>e.classList.remove("hide"), 750)
      })
      const hide = ()=>{
        clearTimeout(infoTimer);
        e.classList.add("hide")
      }
      e.parentElement.addEventListener("mouseleave", hide)
      e.parentElement.addEventListener("click", hide)
      e.parentElement.querySelector("input").addEventListener("focus", hide);
    });
    const setNetwork = async (ssid, pwd)=>{
      const response = await fetch("/setNetwork", {
        method : "POST",
        body : `${ssid}, ${pwd}`
      });
      return response1.status;
    }
    document.querySelector("form").addEventListener("submit", async (event)=>{
      event.preventDefault();
      const {value : ssid} = event.target[0];
      const {value : pwd} = event.target[1];
      setNetwork(ssid, pwd)
        .then((data)=>console.log(data, "sent"))
        .catch(()=>console.log("error"))
      return false;
    })
    const fireplace = document.querySelector(".fireplace div");
    const fireplaceWrapper = document.querySelector(".fireplace");
    setInterval(()=>{
      fireplace.classList.toggle("mirror")
      fireplaceWrapper.style.transform= `rotate(${(Math.random() * 2 -1) * 15}deg)`
    }, 120);
  </script>
</body>
)==";

// used for $upload.htm
static const char notFoundContent[] PROGMEM = R"==(
<!doctype html>
<html lang='en'>

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>4🔥4</title>
  <style>
    html, body{
      overflow: hidden;
      height: 100%;
      background: rgb(35, 25, 25);
      color: rgb(225, 235, 235);
    }
    body{
        display: flex;
        text-align: center;
        justify-content: center;
        align-items: center;
        flex-direction: column;
    }
    .fireplace{
      font-size: 10em;
    } 
    .mirror{
      transform: scaleX(-1);
    } 
  </style>
</head>
<body>
  <div class="fireplace">
    <div>🔥</div>
  </div>
  <h3>incendie</h3>
  <h1>Rien à brûler ici.</h1>
  <script type="text/javascript">
    const fireplace = document.querySelector(".fireplace div");
    const fireplaceWrapper = document.querySelector(".fireplace");
    setInterval(()=>{
      fireplace.classList.toggle("mirror")
      fireplaceWrapper.style.transform= `rotate(${(Math.random() * 2 -1) * 15}deg)`
    }, 120);
  </script>
</body>
)==";