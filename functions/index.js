const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);
var XMLHttpRequest = require('xmlhttprequest').XMLHttpRequest;

var db = admin.database();
var ref = db.ref();

exports.updateItem = functions.https.onRequest((request, response) => {
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() { 
        if (this.readyState == 4 && this.status == 200) { 
            var res = JSON.parse(xhttp.responseText);
            
            ref.child('info').set({
                id: res['deal']['id'],
                title: res['deal']['title'],
                description: res['deal']['features'],
                photos: res['deal']['photos']
            });
            ref.child('settings').set({
                accentColor: res['deal']['theme']['accentColor'],
                backgroundColor: res['deal']['theme']['backgroundColor'],
                foreground: res['deal']['theme']['foreground']
            });
        }
    };
    xhttp.open('GET', 'https://api.meh.com/1/current.json?apikey=KEY', true);
    xhttp.send();
    response.send('Updated.');
});