class Stack<T> {
    late List<T?> stack;
    int lastUsedIndex = -1;
    
    Stack([int size=0]) {
        stack = new List.filled(size, null);
    }

    bool isFull() {
        return lastUsedIndex >= stack.length - 1;
    }

    bool isEmpty() {
        return lastUsedIndex < 0;
    }

    void push(T data) {
        if (lastUsedIndex < stack.length - 1) {
            stack[++lastUsedIndex] = data;
        } else {
            throw "stack overflow";
        }
    }

    T pop() {
        if (lastUsedIndex >= 0) {
            T temp = stack[lastUsedIndex]!;
            stack[lastUsedIndex--] = null;
            return temp;
        } else {
            throw "stack underflow";
        }
    }

    T peek([int index=-1]) {
        if (index == -1) {
            index = lastUsedIndex;
        }
        if (index >= 0 && index <= lastUsedIndex) {
            return stack[index]!;
        } else {
            throw "stack empty";
        }
    }

    void clear() {
        stack = new List.filled(this.stack.length, null);
        lastUsedIndex = -1;
    }

    int size() {
        return lastUsedIndex + 1;
    }

    String toString() {
        String out = "Stack{\n";
        for (int i = 0; i < size(); i++) {
            out += "${stack[i]}\n";
        }
        return out + "}";
    }
}