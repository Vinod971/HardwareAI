with open("weights_binary.txt", "w") as f:
    for _ in range(26):
        f.write(" ".join(["00000001"] * 128) + "\n")
