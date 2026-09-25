# Analyzing-the-importance-of-recycling

An interactive recycling game developed in **Lua** using the **LÖVE2D** framework.

The project aims to make learning about household waste sorting more interactive and engaging. Players must identify different types of waste and select the correct recycling bin while the waste objects fall from the top of the screen.

## 🎮 How the Game Works

The player controls a recycling bin at the bottom of the screen.

Waste objects appear randomly and fall toward the bin. Before catching an object, the player must select the correct recycling category.

- Correct classification: **+1 point**
- Incorrect classification: **-1 point**
- The game is completed when the player reaches **50 points**

As the score increases, waste objects appear more frequently and fall faster.

## 🕹️ Game Modes

### Easy Mode
Contains 3 waste categories:

- Mixed
- Plastic
- Glass

### Normal Mode
Contains all 5 categories:

- Mixed
- Organic
- Glass
- Paper
- Plastic

## ⌨️ Controls

### Movement
- `←` / `A` — Move left
- `→` / `D` — Move right

### Select Recycling Bin
Use the number keys (`1–5`) to select the appropriate waste category.

### Other Controls
- `R` — Restart game
- `M` — Return to menu
- `ESC` — Quit

## 🚀 Running the Project

1. Install **LÖVE2D** from the official website.
2. Download or clone this project.
3. Make sure `main.lua` is inside the project folder.
4. Run the folder using LÖVE2D.

For example:

    love .

## 🛠️ Technologies

- **Lua**
- **LÖVE2D**

## 🎯 Project Goal

The goal of this project is to explore whether a simple educational game can help users practice and remember basic household recycling categories.

The game combines repetition, immediate feedback, random waste generation and progressively increasing difficulty to create an interactive learning experience.

## 🔮 Future Improvements

Possible future improvements include:

- Real images or sprites instead of simple waste labels
- Sound effects
- More detailed recycling categories
- Explanations after incorrect answers
- Recycling rules adapted to different countries
- AI-generated feedback and explanations

## 👩‍💻 Author

**Alexandra Ene**  
Bachelor Summer Project  
University of Luxembourg
