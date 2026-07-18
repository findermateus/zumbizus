// Recuperação do Juice (Suaviza escala e tremor)
scale_x = lerp(scale_x, 1, 0.15);
scale_y = lerp(scale_y, 1, 0.15);
shake_power = max(0, shake_power - shake_decay);

// Gerencia o processo de morte (usa o método configurado no Create)
if (isDying) {
    processDeath();
}