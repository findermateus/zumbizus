if (!instance_exists(obj_player)) exit;
    
var _floatOffset = sin(floatTimer) * 4; 
    
var _guiX = roomToGuiX(obj_player.x) + offsetX + shakeX;
var _guiY = roomToGuiY(obj_player.y) + offsetY + shakeY + _floatOffset + slideY;

draw_set_alpha(alpha);
draw_set_color(c_white);
draw_set_font(fnt_gui_default);

if (drawType == "text") {
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
        
    drawTextShadow(_guiX + 2, _guiY + 2, promptText, alpha, 2, scale);
    draw_text_transformed(_guiX, _guiY, promptText, scale, scale, 0); 
} 

if (drawType == "sprite") {
    if (sprite_exists(promptSprite)) {
        draw_sprite_ext(promptSprite, promptSubimg, _guiX, _guiY, scale, scale, 0, c_white, alpha);
    }
}

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);