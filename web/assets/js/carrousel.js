// partie transition et positionnement initial géré en css

const imageCount = [1, 2, 3, 4, 5];
const panneau = document.getElementById('panneau');
let numImage = 1;

for (let i = 0; i < imageCount.length; i++) {
    let div = document.createElement('div');
    div.classList.add('imageCount-img');
    let img = document.createElement('img');
    div.append(img);
    img.src = '/assets/img/home' + (i + 1) + '.jpg'
    panneau.append(div);
}

function anim() {
    panneau.style.left = '-' + (numImage * 100) + 'vw';

    // pour faire repartir les images à 0
    numImage = (numImage + 1) % 5;
}

setInterval(anim, 4000);