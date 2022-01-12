# Rosario
A means to produce a rosario epub book one can read beginning to end completing the Rosario in Spanish

## ePUB

Using the ePub publication container to allow for repeating structures without consuming duplicate pages.
The binder will allocate all pages in sequence, and segment each weekday to practice the Rosario.

The pages of W3C for epub specification are used as reference: https://www.w3.org/publishing/epub3/epub-spec.html

## Sequence

1. Señal de la cruz
2. Credo
3. Padrenuestro
4. Ave Maria
5. Ave Maria 
6. Ave Maria 
7. Gloria
8. Mysterio 1
9. Padre Nuestro
10. Ave Maria x10
11. Gloria
12. Jaculatoria
13. Mysterio 2
14. ...9-12
15. Mysterio 3
16. ... 9-12
17. Mysterio 4
18. ...9-12
19. Mysterio 5
20. ..9-12
21. Letanías de la virgen
22. Ángel de la Guarda
23. Oración de San Miguel Arcángel 

# Compile

Create file with: 
```PowerShell
Compress-Archive -Path . -DestinationPath ./Rosario.epub -Force
```