extension Bool {
    static func ^^ (x: Bool, y: Bool) -> Bool {
        return x && !y || !x && y
    }
}
