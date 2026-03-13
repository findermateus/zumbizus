// --- ENUM DE INTENSIDADE ---
// Definido fora para ser acessível por qualquer objeto
enum soundIntensity {
    low,
    standard,
    high
}

father = noone;
radiusMax = 120;
thickness = 12;
thicknessCurrent = thickness;
currentRadius = 0;
currentAlpha = 1;
echoRadius = 0;

// --- MÉTODO DE INTENSIDADE ---
function setIntensity(_level) {
    switch(_level) {
        case soundIntensity.low:
            thickness = 2;
            currentAlpha = 0.3;
            break;
            
        case soundIntensity.standard:
            thickness = 6;
            currentAlpha = 0.6;
            break;
            
        case soundIntensity.high:
            thickness = 12;
            currentAlpha = 1.0;
            break;
    }
    
    thicknessCurrent = thickness;
}