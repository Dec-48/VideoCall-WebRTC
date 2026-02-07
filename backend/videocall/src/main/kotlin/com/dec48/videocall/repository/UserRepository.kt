package com.dec48.videocall.repository

import com.dec48.videocall.model.User
import org.springframework.stereotype.Repository

@Repository
class UserRepository {
    private var count = 0
    private val users = ArrayList<User>()

    fun generateId(): Int {
        ++count
        return count
    }

    fun save(email: String, hashedPassword: String): User {
        val user = User(
            id = generateId(),
            email = email,
            hashedPassword = hashedPassword
        )
        users.add(user)
        return user
    }

    fun findByEmail(email: String): User? {
        val user = users.find { it.email == email }
        return user
    }
}