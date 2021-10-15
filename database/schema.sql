USE db;
CREATE TABLE `user` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL UNIQUE,
    `hash` VARCHAR(255) NOT NULL,
    `isAdmin` BOOLEAN NOT NULL,
    PRIMARY KEY (`id`)
);

CREATE TABLE `reminder` (
    `time` DATETIME NOT NULL DEFAULT NOW(),
    `type` INT NOT NULL,
    PRIMARY KEY (`time`)
);

CREATE TABLE `drinking` (
    `time` DATETIME NOT NULL DEFAULT NOW(),
    `amount` INT NOT NULL,
    PRIMARY KEY (`time`)
);

CREATE TABLE `goal` (
    `time` DATETIME NOT NULL DEFAULT NOW(),
    `amount` INT NOT NULL,
    PRIMARY KEY (`time`)
);
