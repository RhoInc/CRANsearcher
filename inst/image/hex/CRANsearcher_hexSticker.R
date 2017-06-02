library(hexSticker)

img <- "https://www.elekta.com/dam/jcr:07cffa31-d014-433d-a1b1-f6d35cd51151/cloud.png"

sticker(img,
        package="CRANsearcher",
        p_size=15, p_y = 0.6,
        s_x=1, s_y=1.2,  # position
        s_width=0.95, s_height=1.1,
        h_fill = "white", h_color="#4E94B5", p_color = "#4E94B5",
        filename="inst/image/hex/CRANsearcher_hexSticker.png")
